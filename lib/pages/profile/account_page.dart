import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/pages/profile/change_password_page.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.uid)
        .get();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              return SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        enabled: false,
                        leading: FaIcon(FontAwesomeIcons.solidUser,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .color),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Benutzername',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  user!['username'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ListTile(
                        enabled: false,
                        leading: Icon(Icons.email,
                            color: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .color),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  user['email'],
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.password),
                        trailing: Icon(Icons.chevron_right,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        title: const Text('Passwort ändern'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error),
                        title: Text('Account löschen',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold)),
                        onTap: confirmDeleteUser,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
    );
  }

  void confirmDeleteUser() {
    showConfirmMessage(
        "Account löschen",
        "Dieser Prozess kann nicht rückgängig gemacht werden. Möchtest du deinen Account und alle Daten löschen?",
        deleteUser);
  }

  Future deleteUser() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser!.uid)
          .delete();
      await currentUser!.delete();

      if (mounted) Navigator.of(context).pop();

      showSuccessMessage(
          'Dein Account und deine Daten wurden erfolgreich gelöscht.');
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          showErrorMessage(context,
              'Dieser Vorgang erfordert eine aktuelle Authentifizierung. Melde dich erneut an und versuche es noch einmal.');
        }
      } else if (e.code == 'invalid-email') {
        if (mounted) showErrorMessage(context, 'E-Mail Adresse ungültig!');
      } else if (e.code == 'user-not-found') {
        if (mounted) {
          showErrorMessage(context, 'E-Mail Adresse nicht gefunden!');
        }
      }
    }
  }

  void showConfirmMessage(
    String title,
    String content,
    Future Function() onConfirmTap,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final cs = Theme.of(context).colorScheme;
          return AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer.withAlpha(76),
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.error.withAlpha(25),
                ),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 32,
                color: cs.error,
              ),
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(content, textAlign: TextAlign.center),
            actions: [
              Row(
                children: [
                  DialogButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: "Nein"),
                  DialogButton(
                    onTap: onConfirmTap,
                    text: "Ja",
                    isDestructive: true,
                  ),
                ],
              )
            ],
          );
        });
  }

  void showSuccessMessage(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop();
        });
        return AlertDialog(
          title: Center(
            child: Text(
              message,
            ),
          ),
        );
      },
    );
  }
}
