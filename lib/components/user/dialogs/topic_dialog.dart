import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/content/topic.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';

class TopicDialog extends StatefulWidget {
  final String subjectId;
  final String categoryId;
  final Topic? topic;

  const TopicDialog({
    super.key,
    required this.subjectId,
    required this.categoryId,
    this.topic,
  });

  @override
  State<TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<TopicDialog> {
  final ContentService _contentService = ContentService();
  final nameController = TextEditingController();
  late String _currentStatus;
  bool _isDirty = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.topic != null) {
      nameController.text = widget.topic!.name;
      _currentStatus = widget.topic!.status;
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

    if (widget.topic == null) {
      final newItem = Topic(
        id: '',
        name: nameController.text,
        authorId: user.uid,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _contentService.addTopic(
        widget.subjectId,
        widget.categoryId,
        newItem,
      );
    } else {
      await _contentService.updateTopic(
        widget.subjectId,
        widget.categoryId,
        widget.topic!.id,
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
    final isEditing = widget.topic != null;
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withAlpha(76),
          shape: BoxShape.circle,
          border: Border.all(
            color: cs.primary.withAlpha(25),
          ),
        ),
        child: Icon(
          isEditing ? Icons.edit : Icons.add,
          size: 32,
          color: cs.primary,
        ),
      ),
      title: Text(
        isEditing ? "Thema bearbeiten" : "Neues Thema erstellen",
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: "Name des Themas",
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
          const SizedBox(height: 8),
        ],
      ),
      actions: [
        Row(
          children: [
            DialogButton(
              text: "Abbrechen",
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            DialogButton(
              text: isEditing ? "Speichern" : "Erstellen",
              onTap: () {
                String statusToSave = _currentStatus;
                if (widget.topic == null) {
                  statusToSave = UserConstants.statusPrivate;
                } else {
                  if (_isDirty) {
                    statusToSave = UserConstants.statusPrivate;
                  }
                }
                _save(statusToSave);
              },
            ),
          ],
        ),
      ],
    );
  }
}
