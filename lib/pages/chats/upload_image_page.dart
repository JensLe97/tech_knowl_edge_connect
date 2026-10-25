import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagePage extends StatelessWidget {
  final void Function(ImageSource) sendImage;

  const UploadImagePage({super.key, required this.sendImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Foto aufnehmen'),
          onTap: () {
            Navigator.pop(context);
            sendImage(ImageSource.camera);
          },
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Aus Galerie auswählen'),
          onTap: () {
            Navigator.pop(context);
            sendImage(ImageSource.gallery);
          },
        ),
      ],
    );
  }
}
