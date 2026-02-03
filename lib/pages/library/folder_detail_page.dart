import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/dialog_button.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/show_error_message.dart';
import 'package:tech_knowl_edge_connect/models/idea_folder.dart';
import 'package:tech_knowl_edge_connect/pages/library/gen_learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/pages/library/summary_page.dart';
import 'package:tech_knowl_edge_connect/services/learning_material_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_tile.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech_service.dart';

class FolderDetailPage extends StatefulWidget {
  final IdeaFolder folder;
  const FolderDetailPage({Key? key, required this.folder}) : super(key: key);

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  Future<void> _confirmAndDeleteFolder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordner und Inhalte löschen?'),
        content: const Text(
            'Möchtest du diesen Ordner und alle darin enthaltenen Lerninhalte unwiderruflich löschen?'),
        actions: [
          DialogButton(
              onTap: () => Navigator.of(context).pop(false), text: 'Abbrechen'),
          DialogButton(
              onTap: () => Navigator.of(context).pop(true), text: 'Löschen'),
        ],
      ),
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

  Future<void> _showFileSelector() async {
    if (userId == null) return;
    showModalBottomSheet(
        backgroundColor: Theme.of(context).colorScheme.surface,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: "Foto aufnehmen",
                      onPressed: () async {
                        _pickAndUploadImageOrVideo(ImageSource.camera, "image");
                      },
                      icon: const Icon(Icons.camera_alt),
                    ),
                    IconButton(
                      tooltip: "Foto aus Galerie auswählen",
                      onPressed: () async {
                        _pickAndUploadImageOrVideo(
                            ImageSource.gallery, "image");
                      },
                      icon: const Icon(Icons.image),
                    ),
                    IconButton(
                      tooltip: "Video aufnehmen",
                      onPressed: () async {
                        _pickAndUploadImageOrVideo(ImageSource.camera, "video");
                      },
                      icon: const Icon(Icons.video_call),
                    ),
                    IconButton(
                      tooltip: "Video aus Galerie auswählen",
                      onPressed: () async {
                        _pickAndUploadImageOrVideo(
                            ImageSource.gallery, "video");
                      },
                      icon: const Icon(Icons.video_file),
                    ),
                    IconButton(
                      tooltip: "Datei auswählen",
                      onPressed: () async {
                        await _pickAndUploadFile();
                      },
                      icon: const Icon(Icons.attach_file),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
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
    final result = await FilePicker.platform.pickFiles(
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
    if (mounted) Navigator.of(context).pop(); // Close the modal bottom sheet
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
    final urls = materials.map((m) => m.url).toList();
    final mimeTypes =
        materials.map((m) => LearningMaterialType.getMimeType(m.type)).toList();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryPage(
            name: widget.folder.name,
            urls: urls,
            mimeTypes: mimeTypes,
            aiTechService: _aiTechService,
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
    final urls = materials.map((m) => m.url).toList();
    final mimeTypes =
        materials.map((m) => LearningMaterialType.getMimeType(m.type)).toList();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GenLearningBitePage(
            name: widget.folder.name,
            urls: urls,
            mimeTypes: mimeTypes,
            aiTechService: _aiTechService,
          ),
        ),
      );
    }
  }

  final LearningMaterialService _materialService = LearningMaterialService();
  final AiTechService _aiTechService = AiTechService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final String? userName =
      FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymer User';
  late Future<List<LearningMaterial>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _materialService.getLearningMaterials(
      userId: userId!,
      folderId: widget.folder.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            elevation: 0,
            shadowColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles),
                tooltip: 'Dokumente zusammenfassen',
                onPressed: _summarizeMaterials,
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.schoolCircleCheck),
                tooltip: 'Learning Bite erstellen',
                onPressed: _generateLearningBite,
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.folderMinus),
                tooltip: 'Ordner löschen',
                onPressed: _confirmAndDeleteFolder,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                tooltip: 'Lerninhalt hochladen',
                onPressed: _showFileSelector,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsetsDirectional.only(top: 10, bottom: 10),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.folder.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (widget.folder.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.folder.description,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.normal),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              background: Stack(children: [
                OverflowBox(
                  maxWidth: 800,
                  maxHeight: 800,
                  child: FaIcon(
                    FontAwesomeIcons.folder,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 50,
                  ),
                ),
              ]),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: FutureBuilder<List<LearningMaterial>>(
                future: _materialsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Fehler: \\${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Erstelle einen neuen Lerninhalt",
                              style: TextStyle(fontSize: 20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "über das ",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Icon(Icons.add_circle),
                                Text(
                                  " oben rechts.",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                          ],
                        )),
                      ),
                    );
                  }
                  final materials = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 200 / 155,
                      ),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
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
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.trash,
                                      size: 21),
                                  tooltip: 'Löschen',
                                  onPressed: () async {
                                    await _materialService
                                        .deleteLearningMaterial(
                                      materialId: material.id,
                                      fileUrl: material.url,
                                    );
                                    setState(() {
                                      _materialsFuture =
                                          _materialService.getLearningMaterials(
                                        userId: userId!,
                                        folderId: widget.folder.id,
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
