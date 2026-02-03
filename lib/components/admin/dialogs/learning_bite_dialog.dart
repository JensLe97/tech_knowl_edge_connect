import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class LearningBiteDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String userId;
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String conceptId;
  final String? learningBiteId;
  final Map<String, dynamic>? existingData;

  const LearningBiteDialog({
    super.key,
    required this.adminService,
    required this.userId,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    required this.conceptId,
    this.learningBiteId,
    this.existingData,
  });

  @override
  State<LearningBiteDialog> createState() => _LearningBiteDialogState();
}

class _LearningBiteDialogState extends State<LearningBiteDialog> {
  late TextEditingController _titleController;
  late String _status;
  late int _version;
  late String _type;
  late IconData _selectedIcon;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingData?['title'] ?? '');
    _status = widget.existingData?['status'] ?? 'Draft';
    _version = (widget.existingData?['version'] ?? 1) as int;
    _type = widget.existingData?['type'] ?? 'lesson';
    _completed = widget.existingData?['completed'] ?? false;

    // Initialize Icon
    final iconMap = widget.existingData?['iconData'];
    if (iconMap is Map) {
      _selectedIcon = IconData(
        iconMap['codePoint'],
        fontFamily: iconMap['fontFamily'],
        fontPackage: iconMap['fontPackage'],
      );
    } else {
      _selectedIcon = AdminConstants.availableIcons.values.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.learningBiteId == null
          ? 'Learning Bite hinzufügen'
          : 'Learning Bite bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Titel'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: AdminConstants.learningBiteTypes.contains(_type)
                  ? _type
                  : AdminConstants.learningBiteTypes.first,
              items: AdminConstants.learningBiteTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
              decoration: const InputDecoration(labelText: 'Typ'),
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
            CheckboxListTile(
              title: const Text('Abgeschlossen'),
              value: _completed,
              onChanged: (val) => setState(() => _completed = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            const Text('Icon wählen:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AdminConstants.availableIcons.entries.map((entry) {
                final isSelected =
                    _selectedIcon.codePoint == entry.value.codePoint;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = entry.value),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary)
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(entry.value,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null),
                  ),
                );
              }).toList(),
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
            if (_titleController.text.trim().isEmpty) return;

            final iconDataMap = {
              'codePoint': _selectedIcon.codePoint,
              'fontFamily': _selectedIcon.fontFamily,
              'fontPackage': _selectedIcon.fontPackage,
            };

            try {
              if (widget.learningBiteId == null) {
                await widget.adminService.createLearningBite(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  conceptId: widget.conceptId,
                  title: _titleController.text.trim(),
                  content: [],
                  type: _type,
                  status: _status,
                  version: _version,
                  userId: widget.userId,
                  iconData: iconDataMap,
                  completed: _completed,
                );
              } else {
                await widget.adminService.updateLearningBite(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  conceptId: widget.conceptId,
                  learningBiteId: widget.learningBiteId!,
                  data: {
                    'title': _titleController.text.trim(),
                    'type': _type,
                    'status': _status,
                    'version': _version,
                    'updatedBy': widget.userId,
                    'iconData': iconDataMap,
                    'completed': _completed,
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
