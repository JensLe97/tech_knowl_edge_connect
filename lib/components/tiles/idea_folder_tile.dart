import 'package:flutter/material.dart';

class IdeaFolderTile extends StatelessWidget {
  final String title;
  final void Function()? onTap;
  final IconData icon;
  final Color color;

  const IdeaFolderTile({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconTextColor = Theme.of(context).textTheme.bodyLarge!.color;
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 28, color: iconTextColor),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: iconTextColor),
        ),
      ),
    );
  }
}
