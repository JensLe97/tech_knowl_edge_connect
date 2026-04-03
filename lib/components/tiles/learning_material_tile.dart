import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/models/user/learning_material.dart';
import 'package:intl/intl.dart';

class LearningMaterialTile extends StatelessWidget {
  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  final LearningMaterial material;
  final VoidCallback? onTap;
  const LearningMaterialTile({Key? key, required this.material, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(153),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Media Preview or Icon Area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: FaIcon(
                      LearningMaterialType.getIconForType(material.type),
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              // Meta Area
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      material.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(material.createdAt.toDate()),
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
