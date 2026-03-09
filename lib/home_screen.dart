import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supanotes/providers/notes_provider.dart';
import 'package:supanotes/widgets/folders_drawer.dart';
import 'package:supanotes/widgets/notes_list.dart';
import './note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().initialize();
    });
  }

  void _navigateToEditor(BuildContext context, {Map<String, dynamic>? note}) {
    final provider = context.read<NotesProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          folderId: (provider.selectedFolderId ?? -1) > 0 ? provider.selectedFolderId : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, child) {
        if (!provider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.selectedFolderName),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
          drawer: const FoldersDrawer(),
          body: NotesList(
            key: ValueKey(provider.selectedFolderId), // Rebuilds when folder changes
            onNoteTap: (note) => _navigateToEditor(context, note: note),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToEditor(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}