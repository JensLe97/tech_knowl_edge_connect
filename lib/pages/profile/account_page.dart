import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/pages/profile/change_password_page.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_info_message.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String uid) {
    return FirebaseFirestore.instance.collection('Users').doc(uid).snapshots();
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
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firebaseUser = authSnapshot.data;
          if (firebaseUser == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline,
                      size: 64, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(height: 12),
                  const Text('Nicht eingeloggt.'),
                ],
              ),
            );
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: getUserDetails(firebaseUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
              } else if (snapshot.hasData) {
                final userData = snapshot.data!.data();
                final displayName =
                    userData?['username'] ?? firebaseUser.displayName ?? '';
                final emailText =
                    userData?['email'] ?? firebaseUser.email ?? '';
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
                                    displayName,
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
                                'E-Mail',
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
                                    emailText,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          title: const Text('Passwort ändern'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordPage(),
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
            },
          );
        },
      ),
    );
  }

  void confirmDeleteUser() {
    showConfirmMessage(
        "Account löschen",
        "Dieser Prozess kann nicht rückgängig gemacht werden. Möchtest du deinen Account und alle Daten löschen?",
        deleteUser);
  }

  Future deleteUser() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) showErrorMessage(context, 'Nicht eingeloggt.');
        return;
      }

      // Delete Firestore user doc if present (safe even if missing)
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .delete();
      } catch (_) {}

      await user.delete();

      if (!mounted) return;

      Navigator.of(context).pop();

      if (!mounted) return;

      showSuccessMessage(
          'Dein Account und deine Daten wurden erfolgreich gelöscht.');
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        // Try to reauthenticate and then retry deletion
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          showErrorMessage(context, 'Nicht eingeloggt.');
          return;
        }

        final reauthOk = await _attemptReauthentication(user);
        if (reauthOk) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
          try {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .delete();
          } catch (_) {}
          try {
            await FirebaseAuth.instance.currentUser!.delete();
            if (mounted) Navigator.of(context).pop();
            showSuccessMessage(
                'Dein Account und deine Daten wurden erfolgreich gelöscht.');
            return;
          } on FirebaseAuthException catch (e2) {
            if (mounted) Navigator.of(context).pop();
            if (!mounted) return;
            showErrorMessage(
                context, 'Fehler beim Löschen des Accounts: ${e2.message}');
            return;
          }
        } else {
          if (mounted) {
            showErrorMessage(context,
                'Re-Authentifizierung fehlgeschlagen. Bitte melde dich erneut an und versuche es noch einmal.');
          }
          return;
        }
      } else if (e.code == 'invalid-email') {
        showErrorMessage(context, 'E-Mail Adresse ungültig!');
      } else if (e.code == 'user-not-found') {
        showErrorMessage(context, 'E-Mail Adresse nicht gefunden!');
      }
    }
  }

  Future<bool> _attemptReauthentication(User user) async {
    // Prefer password re-auth if available, otherwise attempt Google reauth when possible.
    final providerIds = user.providerData.map((p) => p.providerId).toList();

    if (providerIds.contains('password') && (user.email?.isNotEmpty ?? false)) {
      final password = await _promptForPassword();
      if (password == null) return false;
      try {
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(cred);
        return true;
      } catch (e) {
        if (mounted) {
          showErrorMessage(context, 'Re-Authentifizierung fehlgeschlagen.');
        }
        return false;
      }
    }

    if (providerIds.contains('google.com')) {
      try {
        final gUser = await GoogleSignIn().signIn();
        if (gUser == null) return false;
        final gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: gAuth.accessToken, idToken: gAuth.idToken);
        await user.reauthenticateWithCredential(credential);
        return true;
      } catch (e) {
        if (mounted) {
          showErrorMessage(
              context, 'Google Re-Authentifizierung fehlgeschlagen.');
        }
        return false;
      }
    }

    if (providerIds.contains('apple.com')) {
      try {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        await user.reauthenticateWithCredential(oauthCredential);
        return true;
      } catch (e) {
        if (mounted) {
          showErrorMessage(
              context, 'Apple Re-Authentifizierung fehlgeschlagen.');
        }
        return false;
      }
    }

    // No automatic reauth available for this provider; ask user to sign in again.
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            final textTheme = Theme.of(ctx).textTheme;
            return AlertDialog(
              backgroundColor: cs.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withAlpha(76),
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.primary.withAlpha(25)),
                    ),
                    child: Icon(
                      Icons.login_rounded,
                      size: 32,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erneute Anmeldung erforderlich',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: const Text(
                'Dieser Vorgang erfordert, dass du dich erneut anmeldest. Bitte melde dich ab und erneut an.',
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text('Zum Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Abbrechen'),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false);
    }
    return false;
  }

  Future<String?> _promptForPassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withAlpha(76),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.primary.withAlpha(25)),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 32,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Passwort eingeben',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Passwort'),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: const Text('OK',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  void showConfirmMessage(
    String title,
    String content,
    Future Function() onConfirmTap,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          final cs = Theme.of(dialogContext).colorScheme;
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
                        Navigator.pop(dialogContext);
                      },
                      text: "Nein"),
                  DialogButton(
                    onTap: () {
                      Navigator.pop(dialogContext);
                      Future.microtask(() => onConfirmTap());
                    },
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
    if (!mounted) return;

    final rootNav = Navigator.of(context, rootNavigator: true);

    // Persist pending message so AuthPage can show it if auth-state changes.
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pending_success_message', message);
    });

    // Try to show the info dialog immediately; afterwards navigate to AuthPage.
    // If the dialog cannot be shown for any reason, still navigate to AuthPage.
    try {
      showInfoMessage(rootNav.context, message).then((_) {
        if (!mounted) return;
        rootNav.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => AuthPage(successMessage: message)),
            (route) => false);
      }).catchError((_) {
        if (!mounted) return;
        rootNav.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => AuthPage(successMessage: message)),
            (route) => false);
      });
    } catch (_) {
      if (!mounted) return;
      rootNav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthPage(successMessage: message)),
          (route) => false);
    }
  }
}
