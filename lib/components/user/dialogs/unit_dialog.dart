import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';

class UnitDialog extends StatefulWidget {
  final String subjectId;
  final String categoryId;
  final String topicId;
  final Unit? unit;

  const UnitDialog({
    super.key,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    this.unit,
  });

  @override
  State<UnitDialog> createState() => _UnitDialogState();
}

class _UnitDialogState extends State<UnitDialog> {
  final ContentService _contentService = ContentService();
  final nameController = TextEditingController();
  IconData selectedIcon = UserConstants.availableIcons.values.first;
  late String _currentStatus;
  bool _isDirty = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.unit != null) {
      nameController.text = widget.unit!.name;
      selectedIcon = widget.unit!.iconData;
      _currentStatus = widget.unit!.status;
    } else {
      _currentStatus = UserConstants.statusPrivate;
    }
    nameController.addListener(_markAsDirty);
  }

  void _markAsDirty() {
    if (!mounted) return;
    setState(() {
      if (nameController.text.isNotEmpty) {
        _errorText = null;
      }
      _isDirty = true;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _save(String status) async {
    if (nameController.text.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _errorText = 'Name darf nicht leer sein';
        });
      }
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (widget.unit == null) {
      // Create
      final newItem = Unit(
        id: '',
        name: nameController.text,
        iconData: selectedIcon,
        authorId: user.uid,
        status: status,
      );
      await _contentService.addUnit(
        widget.subjectId,
        widget.categoryId,
        widget.topicId,
        newItem,
      );
    } else {
      // Update
      await _contentService.updateUnit(
        widget.subjectId,
        widget.categoryId,
        widget.topicId,
        widget.unit!.id,
        {
          'name': nameController.text,
          'iconData': {
            'codePoint': selectedIcon.codePoint,
            'fontFamily': selectedIcon.fontFamily,
            'fontPackage': selectedIcon.fontPackage,
          },
          'status': status,
        },
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.unit != null;

    return AlertDialog(
      title: Text(isEditing ? "Einheit bearbeiten" : "Neue Einheit erstellen"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name der Einheit",
                  helperText: ' ',
                  errorText: _errorText,
                ),
              ),
              const SizedBox(height: 16),
              const Text("Icon wählen:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserConstants.availableIcons.values.map((icon) {
                  return GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          selectedIcon = icon;
                          _isDirty = true;
                        });
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        icon,
                        color: selectedIcon == icon
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (isEditing) ...[
                const Divider(),
                Row(
                  children: [
                    const Text("Status: "),
                    Chip(
                      label: Text(
                        UserConstants.statusLabels[_currentStatus] ??
                            _currentStatus,
                      ),
                      backgroundColor:
                          UserConstants.getStatusColor(_currentStatus),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_currentStatus == UserConstants.statusPrivate)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.publish),
                      label: const Text("Veröffentlichen"),
                      onPressed: () => _save(UserConstants.statusPending),
                    ),
                  ),
                if ((_currentStatus == UserConstants.statusPending ||
                    _currentStatus == UserConstants.statusApproved))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.visibility_off),
                      label: const Text("Auf privat setzen"),
                      onPressed: () => _save(UserConstants.statusPrivate),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            String statusToSave = _currentStatus;
            if (widget.unit == null) {
              statusToSave = UserConstants.statusPrivate;
            } else {
              if (_isDirty) {
                statusToSave = UserConstants.statusPrivate;
              }
            }
            _save(statusToSave);
          },
          child: Text(isEditing ? "Speichern" : "Erstellen"),
        ),
      ],
    );
  }
}
