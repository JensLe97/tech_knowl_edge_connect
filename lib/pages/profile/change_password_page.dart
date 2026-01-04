import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/show_error_message.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

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
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Passwort ändern'),
          ],
        ),
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
              return SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 25),
                        LoginTextField(
                          controller: oldPasswordController,
                          hintText: 'Altes Passwort',
                          obscureText: true,
                        ),
                        const SizedBox(height: 25),
                        LoginTextField(
                          controller: newPasswordController,
                          hintText: 'Neues Passwort',
                          obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        LoginTextField(
                          controller: confirmNewPasswordController,
                          hintText: 'Neues Passwort wiederholen',
                          obscureText: true,
                        ),
                        const SizedBox(height: 25),
                        SubmitButton(
                          onTap: () => changeUserPassword(user!['email']),
                          text: "Passwort ändern",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Text("Keine Daten für diesen Benutzer vorhanden.");
            }
          }),
    );
  }

  changeUserPassword(String email) async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      showErrorMessage(context, 'Bitte alle Felder ausfüllen!');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (newPasswordController.text != confirmNewPasswordController.text) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
          showErrorMessage(context, 'Neue Passwörter nicht identisch!');
        }
      } else if (oldPasswordController.text == newPasswordController.text) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) {
          showErrorMessage(context, 'Altes und neues Passwort identisch!');
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: oldPasswordController.text,
        );

        await currentUser!.updatePassword(newPasswordController.text);

        if (mounted) Navigator.of(context).pop();

        showSuccessMessage('Passwort wurde erfolgreich geändert.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          showErrorMessage(context,
              'Dieser Vorgang erfordert eine aktuelle Authentifizierung. Melde dich erneut an und versuche es noch einmal.');
        }
      } else if (e.code == 'weak-password') {
        if (mounted) {
          showErrorMessage(context,
              'Das neue Passwort muss mindestens 6 Zeichen enthalten!');
        }
      } else if (e.code == 'channel-error') {
        if (mounted) {
          showErrorMessage(context, 'Bitte alle Felder korrekt ausfüllen!');
        }
      } else if (e.code == 'invalid-email') {
        if (mounted) {
          showErrorMessage(context, 'Benutzer E-Mail Adresse ungültig!');
        }
      } else if (e.code == 'user-disabled') {
        if (mounted) showErrorMessage(context, 'Benutzer ist gesperrt!');
      } else if (e.code == 'user-not-found') {
        if (mounted) {
          showErrorMessage(context, 'Benutzer wurde nicht gefunden!');
        }
      } else if (e.code == 'wrong-password' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'invalid-credential') {
        if (mounted) {
          showErrorMessage(context, 'Das alte Passwort ist falsch!');
        }
      }
    }
  }

  void showSuccessMessage(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
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
