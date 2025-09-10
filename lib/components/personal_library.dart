import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/idea_folder_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/models/idea_folder.dart';
import 'package:tech_knowl_edge_connect/pages/library/folder_detail_page.dart';
import 'package:tech_knowl_edge_connect/components/idea_folder_tile.dart';
import 'package:tech_knowl_edge_connect/pages/library/create_folder_page.dart';

class PersonalLibrary extends StatefulWidget {
  const PersonalLibrary({Key? key}) : super(key: key);

  @override
  State<PersonalLibrary> createState() => _PersonalLibraryState();
}

class _PersonalLibraryState extends State<PersonalLibrary> {
  Future<void> _navigateToCreateFolderPage() async {
    if (userId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateFolderPage(
          onCreate: (folder) async {
            await _folderService.createFolder(userId: userId!, folder: folder);
            setState(() {
              _foldersFuture = _folderService.getFolders(userId: userId!);
            });
          },
        ),
      ),
    );
  }

  final IdeaFolderService _folderService = IdeaFolderService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  late Future<List<IdeaFolder>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _foldersFuture = _folderService.getFolders(userId: userId!);
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Text('Nicht eingeloggt.');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IdeaFolderTile(
            title: 'Neuen Ordner erstellen',
            isPublic: true,
            icon: Icons.create_new_folder,
            color: Theme.of(context).colorScheme.inversePrimary,
            onTap: _navigateToCreateFolderPage,
            isPublicVisible: false,
          ),
          const SizedBox(height: 0),
          FutureBuilder<List<IdeaFolder>>(
            future: _foldersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Fehler: \\${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final folders = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: folders.length,
                separatorBuilder: (context, index) => const SizedBox(height: 0),
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return IdeaFolderTile(
                    title: folder.name,
                    isPublic: folder.isPublic,
                    icon: Icons.folder,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              FolderDetailPage(folder: folder),
                        ),
                      )
                          .then((folderDeleted) {
                        if (folderDeleted == true) {
                          setState(() {
                            _foldersFuture =
                                _folderService.getFolders(userId: userId!);
                          });
                        }
                      });
                    },
                    onTogglePublic: () async {
                      await _folderService.toggleFolderPublic(
                        userId: userId!,
                        folderId: folder.id,
                        isPublic: !folder.isPublic,
                      );
                      setState(() {
                        _foldersFuture =
                            _folderService.getFolders(userId: userId!);
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
