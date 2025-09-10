import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/square_tile.dart';
import 'package:tech_knowl_edge_connect/components/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/terms_section.dart';
import 'package:tech_knowl_edge_connect/components/show_error_message.dart';
import 'package:tech_knowl_edge_connect/pages/login/forgot_password_page.dart';
import 'package:tech_knowl_edge_connect/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                  'Willkommen bei TechKnowlEdgeConnect',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 25),
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
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ForgotPasswordPage();
                    }));
                  },
                  child: const Text(
                    'Passwort vergessen?',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 25),
                SubmitButton(
                  onTap: signUserIn,
                  text: "Anmelden",
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Oder weiter mit',
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      imagePath: 'images/google.png',
                      onTap: () => AuthService().signInWithGoogle(),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SquareTile(
                      imagePath: 'images/apple.png',
                      onTap: () => AuthService().signInWithApple(),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Noch keinen Account?",
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Jetzt registrieren",
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

  signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'invalid-email' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'channel-error') {
        if (mounted) showErrorMessage(context, 'Anmeldedaten falsch!');
      }
    }
  }
}
