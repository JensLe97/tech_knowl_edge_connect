import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';

class ConceptDialog extends StatefulWidget {
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final Concept? concept;

  const ConceptDialog({
    super.key,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    this.concept,
  });

  @override
  State<ConceptDialog> createState() => _ConceptDialogState();
}

class _ConceptDialogState extends State<ConceptDialog> {
  final ContentService _contentService = ContentService();
  final nameController = TextEditingController();
  late String _currentStatus;
  bool _isDirty = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.concept != null) {
      nameController.text = widget.concept!.name;
      _currentStatus = widget.concept!.status;
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

    if (widget.concept == null) {
      final newItem = Concept(
        id: '',
        name: nameController.text,
        authorId: user.uid,
        status: status,
      );
      await _contentService.addConcept(
        widget.subjectId,
        widget.categoryId,
        widget.topicId,
        widget.unitId,
        newItem,
      );
    } else {
      await _contentService.updateConcept(
        widget.subjectId,
        widget.categoryId,
        widget.topicId,
        widget.unitId,
        widget.concept!.id,
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
    final isEditing = widget.concept != null;

    return AlertDialog(
      title: Text(isEditing ? "Konzept bearbeiten" : "Neues Konzept erstellen"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Name des Konzepts",
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
            if (widget.concept == null) {
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
