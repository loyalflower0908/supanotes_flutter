
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class FoldersDrawer extends StatelessWidget {
  const FoldersDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    Future<void> showAddFolderDialog() async {
      final folderNameController = TextEditingController();
      final formKey = GlobalKey<FormState>();
      // Get the provider before the async gap
      final notesProvider = context.read<NotesProvider>();
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('새 폴더'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: folderNameController,
                decoration: const InputDecoration(labelText: '폴더 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '폴더 이름을 입력하세요.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Use the provider reference from before the await
                    await notesProvider.addFolder(folderNameController.text);
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      );
    }

    Future<void> showRenameFolderDialog(Map<String, dynamic> folder) async {
      final folderNameController = TextEditingController(text: folder['name']);
      final formKey = GlobalKey<FormState>();
      final notesProvider = context.read<NotesProvider>();
      await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('폴더 이름 변경'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: folderNameController,
                decoration: const InputDecoration(labelText: '폴더 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '폴더 이름을 입력하세요.';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await notesProvider.renameFolder(folder['id'], folderNameController.text);
                    if (context.mounted) Navigator.pop(context, folderNameController.text);
                  }
                },
                child: const Text('저장'),
              ),
            ],
          );
        },
      );
    }

    Future<void> showFolderActionsDialog(Map<String, dynamic> folder) async {
      final notesProvider = context.read<NotesProvider>();
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text("'${folder['name']}' 폴더"),
            content: const Text('무엇을 하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showRenameFolderDialog(folder);
                },
                child: const Text('이름 변경'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close the actions dialog
                  final confirm = await showDialog<bool>(
                    context: context, // Use the outer context for the new dialog
                    builder: (confirmDialogContext) => AlertDialog(
                      title: const Text('폴더 삭제'),
                      content: const Text('정말로 이 폴더를 삭제하시겠습니까? 이 폴더에 속한 모든 노트가 함께 영구적으로 삭제됩니다.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(confirmDialogContext, false), child: const Text('취소')),
                        TextButton(
                          onPressed: () => Navigator.pop(confirmDialogContext, true),
                          child: const Text('삭제', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    // Use the provider reference from before the await
                    await notesProvider.deleteFolder(folder['id']);
                  }
                },
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
            ],
          );
        },
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('폴더', style: TextStyle(fontSize: 24)),
          ),
          ListTile(
            title: const Text('모든 노트'),
            selected: provider.selectedFolderId == null,
            onTap: () {
              provider.selectFolder(null, '모든 노트');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('미분류 노트'),
            selected: provider.selectedFolderId == -1,
            onTap: () {
              provider.selectFolder(-1, '미분류 노트');
              Navigator.pop(context);
            },
          ),
          const Divider(),
          if (provider.isLoadingFolders)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...provider.folders.map((folder) {
              return ListTile(
                title: Text(folder['name']),
                selected: provider.selectedFolderId == folder['id'],
                onTap: () {
                  provider.selectFolder(folder['id'], folder['name']);
                  Navigator.pop(context);
                },
                onLongPress: () {
                  showFolderActionsDialog(folder);
                },
              );
            }).toList(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('새 폴더 추가'),
            onTap: showAddFolderDialog,
          ),
        ],
      ),
    );
  }
}
