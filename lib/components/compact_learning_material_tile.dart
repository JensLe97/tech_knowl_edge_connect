import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';

class CompactLearningMaterialTile extends StatelessWidget {
  final LearningMaterial material;
  final void Function()? onTap;

  const CompactLearningMaterialTile({
    super.key,
    required this.material,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FaIcon(
        LearningMaterialType.getIconForType(material.type),
      ),
      title: Text(
        material.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        _formatDate(material.createdAt.toDate()),
        style: const TextStyle(fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}
