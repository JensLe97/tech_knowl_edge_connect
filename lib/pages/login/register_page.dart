import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/login_button.dart';
import 'package:tech_knowl_edge_connect/components/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/terms_section.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Icon(
                  Icons.lock,
                  size: 80,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Neuen Account erstellen',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 25),
                LoginTextField(
                  controller: usernameController,
                  hintText: 'Benutzername',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                LoginTextField(
                  controller: emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                LoginTextField(
                  controller: passwordController,
                  hintText: 'Passwort',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                LoginTextField(
                  controller: confirmPasswordController,
                  hintText: 'Passwort wiederholen',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                LoginButton(
                  onTap: signUserUp,
                  text: "Registrieren",
                ),
                const SizedBox(height: 98),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Bereits einen Account?",
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Jetzt anmelden",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const TermsAndConditions(),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(usernameController.text)) {
        if (mounted) Navigator.of(context).pop();
        showErrorMessage('Benutzername ungültig!');
      } else if (passwordController.text != confirmPasswordController.text) {
        if (mounted) Navigator.of(context).pop();
        showErrorMessage('Passwörter nicht identisch!');
      } else {
        UserCredential? userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        createUserDocument(userCredential);

        if (mounted) Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'weak-password') {
        showErrorMessage('Passwort muss mindestens 6 Zeichen enthalten!');
      } else if (e.code == 'channel-error') {
        showErrorMessage('Bitte alle Felder korrekt ausfüllen!');
      } else if (e.code == 'invalid-email') {
        showErrorMessage('E-Mail Adresse ungültig!');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage('E-Mail Adresse ist bereits registriert!');
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
