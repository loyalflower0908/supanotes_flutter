
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class NotesList extends StatelessWidget {
  final Function(Map<String, dynamic>?) onNoteTap;

  const NotesList({super.key, required this.onNoteTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.notes; // Directly access the notes list

    if (provider.isLoadingFolders && notes.isEmpty) { // Check if folders are loading and notes are empty
      return const Center(child: CircularProgressIndicator());
    }
    
    if (notes.isEmpty) {
      return const Center(child: Text('노트가 없습니다.'));
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: ValueKey(note['id']),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context.read<NotesProvider>().deleteNote(note['id']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("'${note['title'] ?? '제목 없음'}' 노트를 삭제했습니다.")),
            );
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(note['title'] ?? '제목 없음'),
            subtitle: Text(
              note['content'] ?? '내용 없음',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onNoteTap(note),
          ),
        );
      },
    );
  }
}
