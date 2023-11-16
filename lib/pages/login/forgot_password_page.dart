import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/login_button.dart';
import 'package:tech_knowl_edge_connect/components/login_textfield.dart';

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
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .inversePrimary, //change your color here
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 50),
                const Text(
                  'E-Mail zum Zurücksetzten des Passwortes',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 25),
                LoginTextField(
                  controller: emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                LoginButton(
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
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();

      showSendMessage(
          'Eine E-Mail mit dem Link zum Zurücksetzen des Passwortes wurde versendet.');
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'channel-error') {
        showErrorMessage('Bitte E-Mail angeben!');
      } else if (e.code == 'invalid-email') {
        showErrorMessage('E-Mail Adresse ungültig!');
      } else if (e.code == 'user-not-found') {
        showErrorMessage('E-Mail Adresse nicht gefunden!');
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void showSendMessage(String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.of(context).pop();
          if (mounted) Navigator.of(context).pop();
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
