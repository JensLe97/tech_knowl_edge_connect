import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class SubjectDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String userId;
  final String? subjectId;
  final Map<String, dynamic>? existingData;

  const SubjectDialog({
    super.key,
    required this.adminService,
    required this.userId,
    this.subjectId,
    this.existingData,
  });

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _status;
  late int _version;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingData?['description'] ?? '');
    _status = widget.existingData?['status'] ?? 'Draft';
    _version = (widget.existingData?['version'] ?? 1) as int;

    // Initialize Color
    final colorVal = widget.existingData?['color'];
    if (colorVal is int) {
      _selectedColor = Color(colorVal);
    } else {
      _selectedColor = AdminConstants.availableColors.values.first;
    }

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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.subjectId == null ? 'Fach hinzufügen' : 'Fach bearbeiten'),
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
            const SizedBox(height: 16),
            const Text('Farbe wählen:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AdminConstants.availableColors.entries.map((entry) {
                final isSelected = _selectedColor.value == entry.value.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = entry.value),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
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
            if (_nameController.text.trim().isEmpty) return;

            final iconDataMap = {
              'codePoint': _selectedIcon.codePoint,
              'fontFamily': _selectedIcon.fontFamily,
              'fontPackage': _selectedIcon.fontPackage,
            };

            try {
              if (widget.subjectId == null) {
                await widget.adminService.createSubject(
                  name: _nameController.text.trim(),
                  description: _descriptionController.text.trim(),
                  status: _status,
                  version: _version,
                  userId: widget.userId,
                  color: _selectedColor.value,
                  iconData: iconDataMap,
                );
              } else {
                await widget.adminService.updateSubject(
                  subjectId: widget.subjectId!,
                  data: {
                    'name': _nameController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'status': _status,
                    'version': _version,
                    'color': _selectedColor.value,
                    'iconData': iconDataMap,
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
