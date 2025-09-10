import 'package:flutter/material.dart';

typedef TogglePublicCallback = void Function();

class IdeaFolderTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final IconData icon;
  final Color color;
  final bool isPublic;
  final bool isPublicVisible;
  final TogglePublicCallback? onTogglePublic;

  const IdeaFolderTile({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
    this.isPublic = true,
    this.isPublicVisible = true,
    this.onTogglePublic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTextColor = Theme.of(context).textTheme.bodyLarge!.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, size: 28, color: iconTextColor),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: iconTextColor),
              ),
            ),
            if (isPublicVisible)
              Expanded(
                child: GestureDetector(
                  onTap: onTogglePublic,
                  child: Icon(
                    isPublic ? Icons.public : Icons.lock,
                    color: iconTextColor,
                    size: 28,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
