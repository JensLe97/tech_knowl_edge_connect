import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/forms/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/buttons/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/library/terms_section.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_background.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),

              // App Icon / Logo Area
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withAlpha(153),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outline.withAlpha(12),
                  ),
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 32,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Neuen Account erstellen',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Werde Teil der Community',
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              LoginTextField(
                controller: usernameController,
                hintText: 'Benutzername',
                obscureText: false,
                textInputAction: TextInputAction.next,
                prefixIcon:
                    Icon(Icons.person_outline, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              LoginTextField(
                controller: emailController,
                hintText: 'E-Mail',
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon:
                    Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              LoginTextField(
                controller: passwordController,
                hintText: 'Passwort',
                obscureText: _obscureText,
                textInputAction: TextInputAction.next,
                prefixIcon:
                    Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),

              LoginTextField(
                controller: confirmPasswordController,
                hintText: 'Passwort wiederholen',
                obscureText: _obscureConfirmText,
                textInputAction: TextInputAction.done,
                prefixIcon:
                    Icon(Icons.lock_reset_outlined, color: cs.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmText = !_obscureConfirmText;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SubmitButton(
                onTap: signUserUp,
                text: "Registrieren",
              ),
              const SizedBox(height: 32),

              // Login Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bereits einen Account?",
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: widget.onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Jetzt anmelden",
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const TermsAndConditions(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  signUserUp() async {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showErrorMessage(context, 'Bitte alle Felder ausfüllen!');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16)),
              child: const CircularProgressIndicator()),
        );
      },
    );

    try {
      if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(usernameController.text)) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) showErrorMessage(context, 'Benutzername ungültig!');
      } else if (passwordController.text != confirmPasswordController.text) {
        if (mounted) Navigator.of(context).pop();
        if (mounted) showErrorMessage(context, 'Passwörter nicht identisch!');
      } else {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        createUserDocument(userCredential);

        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'weak-password') {
        if (mounted) {
          showErrorMessage(
              context, 'Passwort muss mindestens 6 Zeichen enthalten!');
        }
      } else if (e.code == 'channel-error') {
        if (mounted) {
          showErrorMessage(context, 'Bitte alle Felder korrekt ausfüllen!');
        }
      } else if (e.code == 'invalid-email') {
        if (mounted) showErrorMessage(context, 'E-Mail Adresse ungültig!');
      } else if (e.code == 'email-already-in-use') {
        if (mounted) {
          showErrorMessage(context, 'E-Mail Adresse ist bereits registriert!');
        }
      }
    }
  }

  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'uid': userCredential.user!.uid,
      });
    }
  }
}
