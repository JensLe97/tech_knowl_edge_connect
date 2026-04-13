import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/user/idea_folder_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/models/user/idea_folder.dart';
import 'package:tech_knowl_edge_connect/pages/library/folder_detail_page.dart';
import 'package:tech_knowl_edge_connect/components/tiles/idea_folder_tile.dart';
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
          FutureBuilder<List<IdeaFolder>>(
            future: _foldersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Fehler: ${snapshot.error}');
              }
              final folders = snapshot.data ?? [];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: folders.length + 1,
                itemBuilder: (context, index) {
                  if (index == folders.length) {
                    return IdeaFolderTile(
                      title: 'Neuen Ordner erstellen',
                      icon: Icons.create_new_folder,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: _navigateToCreateFolderPage,
                    );
                  }
                  final folder = folders[index];
                  return IdeaFolderTile(
                    title: folder.name,
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
