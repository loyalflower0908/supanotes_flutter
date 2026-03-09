import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';

class NotesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _folders = [];
  List<Map<String, dynamic>> _notes = []; // Added to hold current notes
  StreamSubscription<List<Map<String, dynamic>>>? _notesSubscription; // Added for stream management
  Stream<List<Map<String, dynamic>>>? _rawNotesStream; // Changed to hold the raw stream
  int? _selectedFolderId;
  String _selectedFolderName = '모든 노트';
  bool _isLoadingFolders = true;
  bool _isInitialized = false;

  List<Map<String, dynamic>> get folders => _folders;
  List<Map<String, dynamic>> get notes => _notes; // Expose current notes
  int? get selectedFolderId => _selectedFolderId;
  String get selectedFolderName => _selectedFolderName;
  bool get isLoadingFolders => _isLoadingFolders;
  bool get isInitialized => _isInitialized;

  NotesProvider();

  Future<void> initialize() async {
    if (_isInitialized) return;
    await fetchFolders();
    await _setupNotesListener(); // Call setupNotesListener instead of _setNotesStream
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> fetchFolders() async {
    _isLoadingFolders = true;
    notifyListeners();
    try {
      final data = await supabase.from('folders').select().order('name');
      _folders = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching folders: $e');
    } finally {
      _isLoadingFolders = false;
      notifyListeners();
    }
  }

  // New method to set up stream and listen
  Future<void> _setupNotesListener() async {
    await _notesSubscription?.cancel(); // Cancel previous subscription
    Stream<List<Map<String, dynamic>>> stream;
    final baseStream = supabase.from('notes').stream(primaryKey: ['id']);

    if (_selectedFolderId == null) {
      stream = baseStream.order('updated_at', ascending: false);
    } else if (_selectedFolderId == -1) {
      stream = baseStream.order('updated_at', ascending: false);
    } else {
      stream = baseStream.eq('folder_id', _selectedFolderId!).order('updated_at', ascending: false);
    }
    _rawNotesStream = stream; // Store the raw stream if needed elsewhere

    _notesSubscription = stream.listen((data) {
      _notes = List<Map<String, dynamic>>.from(data);
      if (_selectedFolderId == -1) {
        // Client-side filtering for uncategorized notes
        _notes = _notes.where((note) => note['folder_id'] == null).toList();
      }
      notifyListeners();
    }, onError: (e) {
      print('Error listening to notes stream: $e');
    });
  }

  void selectFolder(int? folderId, String folderName) {
    if (_selectedFolderId == folderId) return;
    _selectedFolderId = folderId;
    _selectedFolderName = folderName;
    _setupNotesListener(); // Call _setupNotesListener to re-listen with new filter
    notifyListeners();
  }

  Future<void> addFolder(String name) async {
    await supabase.from('folders').insert({'name': name});
    await fetchFolders();
  }

  Future<void> renameFolder(int id, String newName) async {
    await supabase.from('folders').update({'name': newName}).eq('id', id);
    if (_selectedFolderId == id) {
      _selectedFolderName = newName;
    }
    await fetchFolders();
  }

  Future<void> deleteFolder(int id) async {
    await supabase.from('folders').delete().eq('id', id);

    // Refresh the folder list for the drawer.
    await fetchFolders();

    // If the user was viewing the deleted folder, switch them to "All Notes".
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
      _selectedFolderName = '모든 노트';
    }

    // In all cases, refresh the notes stream to reflect the deleted notes.
    _setupNotesListener(); // Call _setupNotesListener
    notifyListeners();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel(); // Cancel subscription when provider is disposed
    super.dispose();
  }

  Future<void> deleteNote(int noteId) async {
    try {
      await supabase.from('notes').delete().eq('id', noteId);
      // Immediately remove from local list
      _notes.removeWhere((note) => note['id'] == noteId);
      notifyListeners();
    } catch (e) {
      print('Error deleting note: $e');
      // Optionally, you could show a user-friendly error message here.
    }
  }

  Future<void> saveNote({
    int? id,
    required String title,
    required String content,
    int? folderId,
  }) async {
    if (id == null) {
      await supabase.from('notes').insert({
        'title': title,
        'content': content,
        'folder_id': folderId,
      });
    } else {
      await supabase.from('notes').update({
        'title': title,
        'content': content,
      }).eq('id', id);
    }
    // After saving, ensure the notes list is refreshed
    await _setupNotesListener(); // Re-fetch and update local list
    notifyListeners();
  }
}