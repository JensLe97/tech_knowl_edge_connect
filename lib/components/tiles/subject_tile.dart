import "package:flutter/material.dart";
import "package:tech_knowl_edge_connect/models/content/subject.dart";

class SubjectTile extends StatelessWidget {
  final Subject subject;
  final void Function()? onTap;

  const SubjectTile({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(51),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: -32,
              bottom: -32,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  subject.iconData,
                  size: 160,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: subject.color.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          subject.iconData,
                          color: subject.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.outline,
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
