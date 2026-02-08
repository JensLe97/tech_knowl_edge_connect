import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class ConceptDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String userId;
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String? conceptId;
  final Map<String, dynamic>? existingData;

  const ConceptDialog({
    super.key,
    required this.adminService,
    required this.userId,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    this.conceptId,
    this.existingData,
  });

  @override
  State<ConceptDialog> createState() => _ConceptDialogState();
}

class _ConceptDialogState extends State<ConceptDialog> {
  late TextEditingController _nameController;
  late String _status;
  late int _version;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    _status = widget.existingData?['status'] ?? 'Draft';
    _version = (widget.existingData?['version'] ?? 1) as int;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.conceptId == null
          ? 'Konzept hinzufügen'
          : 'Konzept bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              borderRadius: BorderRadius.circular(12),
              initialValue: AdminConstants.statusOptions.contains(_status)
                  ? _status
                  : AdminConstants.statusOptions.first,
              items: AdminConstants.statusOptions
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(AdminConstants.statusLabels[s] ?? s)))
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
            const SizedBox(height: 8),
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
              if (widget.conceptId == null) {
                await widget.adminService.createConcept(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  name: _nameController.text.trim(),
                  status: _status,
                  version: _version,
                  userId: widget.userId,
                );
              } else {
                await widget.adminService.updateConcept(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  conceptId: widget.conceptId!,
                  data: {
                    'name': _nameController.text.trim(),
                    'status': _status,
                    'version': _version,
                  },
                );
              }
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: $e')),
                );
              }
            }
          },
          child: Text(widget.conceptId == null ? 'Erstellen' : 'Speichern'),
        ),
      ],
    );
  }
}
