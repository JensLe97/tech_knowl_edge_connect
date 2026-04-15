import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/forms/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/buttons/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_info_message.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Passwort ändern'),
        centerTitle: true,
      ),
      body: StreamBuilder<User?>(
          stream: _authStream,
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final firebaseUser = authSnapshot.data;
            if (firebaseUser == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(height: 12),
                    const Text('Nicht eingeloggt.'),
                  ],
                ),
              );
            }

            final email = firebaseUser.email ?? '';

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 25),
                      LoginTextField(
                        controller: oldPasswordController,
                        hintText: 'Altes Passwort',
                        obscureText: _obscureOld,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(Icons.lock_outline,
                            color: cs.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureOld
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureOld = !_obscureOld;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      LoginTextField(
                        controller: newPasswordController,
                        hintText: 'Neues Passwort',
                        obscureText: _obscureNew,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icon(Icons.lock_outline,
                            color: cs.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNew = !_obscureNew;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      LoginTextField(
                        controller: confirmNewPasswordController,
                        hintText: 'Neues Passwort wiederholen',
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icon(Icons.lock_reset_outlined,
                            color: cs.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      SubmitButton(
                        onTap: () {
                          if (email.isEmpty) {
                            showErrorMessage(
                                context, 'Benutzer E-Mail Adresse ungültig!');
                            return;
                          }
                          changeUserPassword(email);
                        },
                        text: "Passwort ändern",
                      ),
                    ],
                  ),
                ),
              ),
            );
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

    final navigator = Navigator.of(context);

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
        if (mounted) navigator.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showErrorMessage(context, 'Neue Passwörter nicht identisch!');
        });
      } else if (oldPasswordController.text == newPasswordController.text) {
        if (mounted) navigator.pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showErrorMessage(context, 'Altes und neues Passwort identisch!');
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: oldPasswordController.text,
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          if (mounted) {
            navigator.pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showErrorMessage(context, 'Benutzer nicht gefunden.');
            });
          }
          return;
        }

        await user.updatePassword(newPasswordController.text);

        if (mounted) navigator.pop();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showInfoMessage(context, 'Passwort wurde erfolgreich geändert.')
              .then((_) {
            if (!mounted) return;
            navigator.pop();
          });
        });
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
}
