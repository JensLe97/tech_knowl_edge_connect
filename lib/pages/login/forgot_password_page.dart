import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/show_error_message.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .inversePrimary, //change your color here
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 80,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 30),
                const Text(
                  'E-Mail zum Zurücksetzen des Passwortes',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 25),
                LoginTextField(
                  controller: emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                SubmitButton(
                  onTap: resetPassword,
                  text: "Passwort zurücksetzen",
                ),
              ],
            ),
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
        return const Center(
          child: CircularProgressIndicator(),
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
