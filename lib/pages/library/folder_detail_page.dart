import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/models/user/idea_folder.dart';
import 'package:tech_knowl_edge_connect/pages/library/gen_learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/pages/library/summary_page.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:tech_knowl_edge_connect/services/user/learning_material_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/models/user/learning_material.dart';
import 'package:tech_knowl_edge_connect/components/tiles/learning_material_tile.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/user/idea_folder_service.dart';

class FolderDetailPage extends StatefulWidget {
  final IdeaFolder folder;
  const FolderDetailPage({Key? key, required this.folder}) : super(key: key);

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  Future<void> _togglePublic() async {
    if (userId == null) return;
    try {
      await _folderService.toggleFolderPublic(
          userId: userId!, folderId: widget.folder.id, isPublic: !_isPublic);
      if (!mounted) return;
      setState(() {
        _isPublic = !_isPublic;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPublic
                ? 'Ordner ist jetzt öffentlich sichtbar'
                : 'Ordner ist jetzt privat'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, 'Fehler beim Ändern des Status: $e');
      }
    }
  }

  Future<void> _confirmAndDeleteMaterial(LearningMaterial material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer.withAlpha(76),
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.error.withAlpha(25),
              ),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 32,
              color: cs.error,
            ),
          ),
          title: const Text(
            'Lerninhalt löschen?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Möchtest du diesen Lerninhalt unwiderruflich löschen?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                DialogButton(
                    onTap: () => Navigator.of(context).pop(false),
                    text: 'Abbrechen'),
                DialogButton(
                    onTap: () => Navigator.of(context).pop(true),
                    text: 'Löschen',
                    isDestructive: true),
              ],
            )
          ],
        );
      },
    );
    if (confirmed == true) {
      await _materialService.deleteLearningMaterial(
        materialId: material.id,
        fileUrl: material.url,
      );
      if (!mounted) return;
      setState(() {
        _materialsFuture = _materialService.getLearningMaterials(
          userId: userId!,
          folderId: widget.folder.id,
        );
      });
    }
  }

  Future<void> _confirmAndDeleteFolder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer.withAlpha(76),
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.error.withAlpha(25),
              ),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 32,
              color: cs.error,
            ),
          ),
          title: const Text(
            'Ordner und Inhalte löschen?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
              'Möchtest du diesen Ordner und alle darin enthaltenen Lerninhalte unwiderruflich löschen?',
              textAlign: TextAlign.center),
          actions: [
            Row(
              children: [
                DialogButton(
                    onTap: () => Navigator.of(context).pop(false),
                    text: 'Abbrechen'),
                DialogButton(
                    onTap: () => Navigator.of(context).pop(true),
                    text: 'Löschen',
                    isDestructive: true),
              ],
            )
          ],
        );
      },
    );
    if (confirmed == true) {
      await _materialService.deleteFolderAndAllMaterials(
        userId: userId!,
        folderId: widget.folder.id,
      );
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    }
  }

  Future<void> _pickAndUploadImageOrVideo(
      ImageSource imageSource, String type) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? postContent;
    if (type == "video") {
      postContent = await imagePicker.pickVideo(source: imageSource);
    } else {
      postContent = await imagePicker.pickImage(source: imageSource);
    }

    if (postContent != null) {
      final ext = postContent.name.contains('.')
          ? postContent.name.split('.').last
          : '';
      final fileName = postContent.path.split("image_picker").last;
      final now = DateTime.now();
      final nowFormatted = DateFormat('dd.MM.yy_HH:mm:ss').format(now);
      final fullName = fileName.replaceAll(fileName, '$nowFormatted.$ext');
      _uploadFile(postContent, fullName);
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: LearningMaterialType.supportedTypes,
    );
    if (result != null && result.files.single.path != null) {
      final file = XFile(result.files.single.path!);
      final fullName = result.files.single.name;
      _uploadFile(file, fullName);
    }
  }

  Future<void> _uploadFile(XFile file, String fullName) async {
    final ext = fullName.contains('.') ? fullName.split('.').last : '';
    final fileNameWithoutExt = fullName.contains('.')
        ? fullName.substring(0, fullName.lastIndexOf('.'))
        : fullName;
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    try {
      final url = kIsWeb
          ? await _materialService.uploadData(
              file, userId!, widget.folder.id, '$id.$ext')
          : await _materialService.uploadFile(
              File(file.path), userId!, widget.folder.id, '$id.$ext');
      final material = LearningMaterial(
        id: id,
        name: fileNameWithoutExt,
        type: ext,
        url: url,
        createdAt: Timestamp.fromDate(now),
        userId: userId!,
        userName: userName!,
        folderId: widget.folder.id,
        isPublic: widget.folder.isPublic,
      );
      await _materialService.addLearningMaterial(
        userId: userId!,
        folderId: widget.folder.id,
        material: material,
      );
      if (!mounted) return;
      setState(() {
        _materialsFuture = _materialService.getLearningMaterials(
          userId: userId!,
          folderId: widget.folder.id,
        );
      });
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, 'Fehler beim Hochladen: $e');
      }
    }
  }

  Future<void> _summarizeMaterials() async {
    final materials = await _materialsFuture;
    if (materials.isEmpty && mounted) {
      showErrorMessage(context, 'Keine Lerninhalte zum Zusammenfassen.');
      return;
    }
    final List<Part> fileParts = [];
    for (final m in materials) {
      try {
        final data = await FirebaseStorage.instance.refFromURL(m.url).getData();
        if (data != null) {
          fileParts.add(
              InlineDataPart(LearningMaterialType.getMimeType(m.type), data));
        }
      } catch (_) {}
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            name: widget.folder.name,
            fileParts: fileParts,
            aiTechGenService: _aiTechGenService,
          ),
        ),
      );
    }
  }

  Future<void> _generateLearningBite() async {
    final materials = await _materialsFuture;
    if (materials.isEmpty && mounted) {
      showErrorMessage(context,
          'Keine Lerninhalte zum Erstellen eines Learning Bites vorhanden.');
      return;
    }
    final List<Part> fileParts = [];
    for (final m in materials) {
      try {
        final data = await FirebaseStorage.instance.refFromURL(m.url).getData();
        if (data != null) {
          fileParts.add(
              InlineDataPart(LearningMaterialType.getMimeType(m.type), data));
        }
      } catch (_) {}
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenLearningBitePage(
            name: widget.folder.name,
            fileParts: fileParts,
            aiTechGenService: _aiTechGenService,
          ),
        ),
      );
    }
  }

  final LearningMaterialService _materialService = LearningMaterialService();
  final AiTechGenService _aiTechGenService = AiTechGenService();
  final IdeaFolderService _folderService = IdeaFolderService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final String? userName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymer User';
  late Future<List<LearningMaterial>> _materialsFuture;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.folder.isPublic;
    _materialsFuture = _materialService.getLearningMaterials(
      userId: userId!,
      folderId: widget.folder.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.folder.name),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: 'Lerninhalt hochladen',
            onSelected: (value) {
              switch (value) {
                case 'camera_image':
                  _pickAndUploadImageOrVideo(ImageSource.camera, 'image');
                case 'gallery_image':
                  _pickAndUploadImageOrVideo(ImageSource.gallery, 'image');
                case 'camera_video':
                  _pickAndUploadImageOrVideo(ImageSource.camera, 'video');
                case 'gallery_video':
                  _pickAndUploadImageOrVideo(ImageSource.gallery, 'video');
                case 'file':
                  _pickAndUploadFile();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'camera_image',
                child: ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Foto aufnehmen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'gallery_image',
                child: ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Foto aus Galerie auswählen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'camera_video',
                child: ListTile(
                  leading: Icon(Icons.video_call),
                  title: Text('Video aufnehmen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'gallery_video',
                child: ListTile(
                  leading: Icon(Icons.video_file),
                  title: Text('Video aus Galerie auswählen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'file',
                child: ListTile(
                  leading: Icon(Icons.attach_file),
                  title: Text('Datei auswählen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'toggle_public':
                  _togglePublic();
                case 'summarize':
                  _summarizeMaterials();
                case 'learning_bite':
                  _generateLearningBite();
                case 'delete':
                  _confirmAndDeleteFolder();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'toggle_public',
                child: ListTile(
                  leading: Icon(_isPublic ? Icons.lock : Icons.public),
                  title: Text(
                      _isPublic ? 'Auf Privat stellen' : 'Veröffentlichen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'summarize',
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.wandMagicSparkles),
                  title: Text('AI Tech Zusammenfassung'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'learning_bite',
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.schoolCircleCheck),
                  title: Text('AI Tech Lektion erstellen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: FaIcon(FontAwesomeIcons.folderMinus,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Ordner löschen',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<LearningMaterial>>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Fehler: ${snapshot.error}'));
            }

            final materials = snapshot.data ?? [];
            final colorScheme = Theme.of(context).colorScheme;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ideensammlung",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      "${materials.length} ${materials.length == 1 ? 'Datei' : 'Dateien'}",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _isPublic ? 'Öffentlich' : 'Privat',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              colorScheme.onSecondaryContainer,
                                          letterSpacing: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.folder.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.folder.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (materials.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open,
                              size: 64, color: colorScheme.outlineVariant),
                          const SizedBox(height: 16),
                          const Text(
                            "Erstelle einen neuen Lerninhalt",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("über das ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurfaceVariant)),
                              Icon(Icons.add,
                                  size: 18, color: colorScheme.primary),
                              Text(" oben rechts.",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 200 / 175,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final material = materials[index];
                          return Stack(
                            children: [
                              LearningMaterialTile(
                                material: material,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LearningMaterialPreviewPage(
                                        url: material.url,
                                        type: material.type,
                                        name: material.name,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 28,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: 'Löschen',
                                  onPressed: () async {
                                    await _confirmAndDeleteMaterial(material);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: materials.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
