import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/category.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';

class CategoryDialog extends StatefulWidget {
  final String subjectId;
  final Category? category;

  const CategoryDialog({
    super.key,
    required this.subjectId,
    this.category,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final ContentService _contentService = ContentService();
  final nameController = TextEditingController();
  late String _currentStatus;
  bool _isDirty = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      nameController.text = widget.category!.name;
      _currentStatus = widget.category!.status;
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

    if (widget.category == null) {
      final newItem = Category(
        id: '',
        name: nameController.text,
        authorId: user.uid,
        status: status,
      );
      await _contentService.addCategory(widget.subjectId, newItem);
    } else {
      await _contentService.updateCategory(
        widget.subjectId,
        widget.category!.id,
        {
          'name': nameController.text,
          'status': status,
        },
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return AlertDialog(
      title:
          Text(isEditing ? "Kategorie bearbeiten" : "Neue Kategorie erstellen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Name der Kategorie",
              helperText: ' ',
              errorText: _errorText,
            ),
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
                  backgroundColor: UserConstants.getStatusColor(_currentStatus),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Abbrechen"),
        ),
        ElevatedButton(
          onPressed: () {
            String statusToSave = _currentStatus;
            if (widget.category == null) {
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
