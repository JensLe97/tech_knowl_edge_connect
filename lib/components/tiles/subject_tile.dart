import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
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
    return Card(
      color: subject.color,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: FaIcon(subject.iconData, size: 25),
        title: Text(
          subject.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
