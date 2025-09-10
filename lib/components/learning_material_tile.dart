import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:intl/intl.dart';

class LearningMaterialTile extends StatelessWidget {
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  final LearningMaterial material;
  final VoidCallback? onTap;
  const LearningMaterialTile({Key? key, required this.material, this.onTap})
      : super(key: key);

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return FontAwesomeIcons.filePdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return FontAwesomeIcons.fileImage;
      case 'mp4':
      case 'mov':
        return FontAwesomeIcons.fileVideo;
      default:
        return FontAwesomeIcons.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 200,
        height: 145,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 5,
                    fit: FlexFit.loose,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FaIcon(_getIconForType(material.type), size: 30),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          material.name,
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(material.createdAt.toDate()),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
