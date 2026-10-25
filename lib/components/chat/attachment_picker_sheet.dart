import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';

/// Shows a bottom sheet with five attachment options (take photo, photo from
/// gallery, record video, video from gallery, pick file).
///
/// After the user makes a selection the sheet is dismissed, the file is picked
/// using the appropriate platform API, and [onFilesAdded] is invoked with the
/// resulting [XFile]s.
Future<void> showAttachmentPickerSheet(
  BuildContext context, {
  required void Function(List<XFile> files) onFilesAdded,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    enableDrag: true,
    builder: (_) =>
        SafeArea(child: _AttachmentPickerSheet(onFilesAdded: onFilesAdded)),
  );
}

class _AttachmentPickerSheet extends StatelessWidget {
  final void Function(List<XFile> files) onFilesAdded;

  const _AttachmentPickerSheet({required this.onFilesAdded});

  Future<void> _pickImageOrVideo(
    BuildContext context,
    ImageSource source,
    bool isVideo,
  ) async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final XFile? picked = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);
    if (picked == null) return;

    final length = await picked.length();
    // 50 MB size limit to prevent OutOfMemory errors when reading bytes
    if (length > 50 * 1024 * 1024) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Die Datei ist zu groß (max. 50 MB erlaubt).'),
          ),
        );
      }
      return;
    }

    onFilesAdded([picked]);
  }

  Future<void> _pickFile(BuildContext context) async {
    Navigator.pop(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: LearningMaterialType.supportedTypes,
    );
    onFilesAdded(result.map((file) => file.xFile).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Foto aufnehmen'),
          onTap: () => _pickImageOrVideo(context, ImageSource.camera, false),
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Foto aus Galerie auswählen'),
          onTap: () => _pickImageOrVideo(context, ImageSource.gallery, false),
        ),
        ListTile(
          leading: const Icon(Icons.video_call),
          title: const Text('Video aufnehmen'),
          onTap: () => _pickImageOrVideo(context, ImageSource.camera, true),
        ),
        ListTile(
          leading: const Icon(Icons.video_file),
          title: const Text('Video aus Galerie auswählen'),
          onTap: () => _pickImageOrVideo(context, ImageSource.gallery, true),
        ),
        ListTile(
          leading: const Icon(Icons.attach_file),
          title: const Text('Datei auswählen'),
          onTap: () => _pickFile(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
