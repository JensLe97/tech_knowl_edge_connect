import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/forms/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/buttons/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_background.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: cs.onSurface,
        ),
      ),
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),

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
                  Icons.vpn_key_outlined,
                  size: 32,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Passwort zurücksetzen',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Gib deine E-Mail-Adresse ein, um einen Link zum Zurücksetzen des Passworts zu erhalten.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              LoginTextField(
                controller: emailController,
                hintText: 'E-Mail',
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon:
                    Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SubmitButton(
                onTap: resetPassword,
                text: "Zurücksetzen",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      showErrorMessage(context, 'Bitte E-Mail angeben!');
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
      await FirebaseAuth.instance.setLanguageCode("de");
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();

      showSendMessage(
          'Eine E-Mail mit dem Link zum Zurücksetzen des Passwortes wurde versendet.');
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'channel-error') {
        if (mounted) showErrorMessage(context, 'Bitte E-Mail angeben!');
      } else if (e.code == 'invalid-email') {
        if (mounted) showErrorMessage(context, 'E-Mail Adresse ungültig!');
      } else if (e.code == 'user-not-found') {
        if (mounted) {
          showErrorMessage(context, 'E-Mail Adresse nicht gefunden!');
        }
      }
    }
  }

  void showSendMessage(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop();
        });

        final cs = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          backgroundColor: cs.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withAlpha(25)),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 32,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'E-Mail gesendet',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
