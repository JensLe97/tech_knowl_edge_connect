import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/admin_functions_service.dart';

class AdminManagementCard extends StatefulWidget {
  final AdminFunctionsService adminFunctions;
  final Future<bool> Function() onEnsureAuthenticated;

  const AdminManagementCard({
    super.key,
    required this.adminFunctions,
    required this.onEnsureAuthenticated,
  });

  @override
  State<AdminManagementCard> createState() => _AdminManagementCardState();
}

class _AdminManagementCardState extends State<AdminManagementCard> {
  final TextEditingController _adminUidController = TextEditingController();
  bool _grantingAdmin = false;
  bool _revokingAdmin = false;
  String? _uidErrorText;

  @override
  void dispose() {
    _adminUidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin-Rechte vergeben',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _adminUidController,
              decoration: InputDecoration(
                labelText: 'UID des Benutzers',
                border: const OutlineInputBorder(),
                errorText: _uidErrorText,
                helperText: ' ',
              ),
              onChanged: (value) {
                if (_uidErrorText != null) {
                  setState(() => _uidErrorText = null);
                }
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _grantingAdmin
                      ? null
                      : () async {
                          final uid = _adminUidController.text.trim();
                          if (uid.isEmpty) {
                            setState(() =>
                                _uidErrorText = 'Bitte gib eine UID ein.');
                            return;
                          }
                          setState(() {
                            _uidErrorText = null;
                            _grantingAdmin = true;
                          });
                          try {
                            final ok = await widget.onEnsureAuthenticated();
                            if (!ok) return;
                            await widget.adminFunctions.setAdmin(uid: uid);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin-Rechte vergeben.'),
                              ),
                            );
                            _adminUidController.clear();
                          } on FirebaseFunctionsException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Fehler: ${e.message ?? e.code}',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fehler beim Setzen der Admin-Rechte.'),
                              ),
                            );
                          } finally {
                            if (context.mounted) {
                              setState(() => _grantingAdmin = false);
                            }
                          }
                        },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: Text(_grantingAdmin
                      ? 'Bitte warten...'
                      : 'Als Admin freischalten'),
                ),
                OutlinedButton.icon(
                  onPressed: _revokingAdmin
                      ? null
                      : () async {
                          final uid = _adminUidController.text.trim();
                          if (uid.isEmpty) {
                            setState(() =>
                                _uidErrorText = 'Bitte gib eine UID ein.');
                            return;
                          }
                          setState(() {
                            _uidErrorText = null;
                            _revokingAdmin = true;
                          });
                          try {
                            final ok = await widget.onEnsureAuthenticated();
                            if (!ok) return;
                            await widget.adminFunctions.revokeAdmin(uid: uid);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Admin-Rechte entzogen.'),
                              ),
                            );
                            _adminUidController.clear();
                          } on FirebaseFunctionsException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Fehler: ${e.message ?? e.code}',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fehler beim Entziehen der Admin-Rechte.'),
                              ),
                            );
                          } finally {
                            if (context.mounted) {
                              setState(() => _revokingAdmin = false);
                            }
                          }
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(
                      _revokingAdmin ? 'Bitte warten...' : 'Admin entziehen'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Hinweis: Der Benutzer muss sich ab- und wieder anmelden, um die Rolle zu sehen.',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
