import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:tech_knowl_edge_connect/models/subject.dart";

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: subject.color,
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
                  child: FaIcon(subject.iconData, size: 25),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subject.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
