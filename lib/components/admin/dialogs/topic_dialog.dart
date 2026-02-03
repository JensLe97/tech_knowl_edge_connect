import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class TopicDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String userId;
  final String subjectId;
  final String categoryId;
  final String? topicId;
  final Map<String, dynamic>? existingData;

  const TopicDialog({
    super.key,
    required this.adminService,
    required this.userId,
    required this.subjectId,
    required this.categoryId,
    this.topicId,
    this.existingData,
  });

  @override
  State<TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<TopicDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _status;
  late int _version;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingData?['description'] ?? '');
    _status = widget.existingData?['status'] ?? 'Draft';
    _version = (widget.existingData?['version'] ?? 1) as int;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.topicId == null ? 'Topic hinzufügen' : 'Topic bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Beschreibung'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: AdminConstants.statusOptions.contains(_status)
                  ? _status
                  : AdminConstants.statusOptions.first,
              items: AdminConstants.statusOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Version'),
              onChanged: (value) {
                _version = int.tryParse(value) ?? 1;
              },
              controller: TextEditingController(text: _version.toString()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.trim().isEmpty) return;
            try {
              if (widget.topicId == null) {
                await widget.adminService.createTopic(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  status: _status,
                  version: _version,
                  userId: widget.userId,
                );
              } else {
                await widget.adminService.updateTopic(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId!,
                  data: {
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'status': _status,
                    'version': _version,
                    'updatedBy': widget.userId,
                  },
                );
              }
              if (!mounted) return;
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler: $e')),
              );
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
