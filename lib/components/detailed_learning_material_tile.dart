import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';

class DetailedLearningMaterialTile extends StatelessWidget {
  final LearningMaterial material;
  final VoidCallback? onTap;

  const DetailedLearningMaterialTile({
    super.key,
    required this.material,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            FaIcon(
              LearningMaterialType.getIconForType(material.type),
              size: 40,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const textStyle = TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      );
                      final resolvedStyle =
                          DefaultTextStyle.of(context).style.merge(textStyle);
                      final textSpan = TextSpan(
                        text: material.name,
                        style: resolvedStyle,
                      );
                      final tp = TextPainter(
                        text: textSpan,
                        maxLines: 2,
                        textDirection: ui.TextDirection.ltr,
                        textScaler: MediaQuery.textScalerOf(context),
                      )..layout(maxWidth: constraints.maxWidth);

                      final lines = tp.computeLineMetrics().length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                          if (lines == 1)
                            const SizedBox(height: 18), // empty second line
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(material.userName),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child:
                                Text(_formatDate(material.createdAt.toDate())),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.solidHeart,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(material.numberOfLikes.toString()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
