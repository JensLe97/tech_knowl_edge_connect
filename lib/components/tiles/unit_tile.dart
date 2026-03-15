import "package:flutter/material.dart";
import "package:tech_knowl_edge_connect/models/content/unit.dart";

class UnitTile extends StatelessWidget {
  final Unit unit;
  final void Function()? onTap;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const UnitTile({
    super.key,
    required this.unit,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(unit.iconData, size: 30),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        unit.name,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
                if (onEdit != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Einheit bearbeiten',
                      onPressed: onEdit,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                if (onDelete != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Einheit löschen',
                      onPressed: onDelete,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
