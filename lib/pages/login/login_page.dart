import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/forms/login_textfield.dart';
import 'package:tech_knowl_edge_connect/components/buttons/social_login_button.dart';
import 'package:tech_knowl_edge_connect/components/buttons/submit_button.dart';
import 'package:tech_knowl_edge_connect/components/library/terms_section.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/show_error_message.dart';
import 'package:tech_knowl_edge_connect/pages/login/forgot_password_page.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_background.dart';
import 'package:tech_knowl_edge_connect/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // App Icon / Logo Area
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color:
                      cs.surfaceContainerHighest.withAlpha(153), // ~60% alpha
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outline.withAlpha(12), // ring-black/5
                  ),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Willkommen bei\nTechKnowlEdgeConnect',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Melde dich an, um fortzufahren',
                style: textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              LoginTextField(
                key: const ValueKey('login_email_field'),
                fieldKey: const ValueKey('login_email'),
                controller: emailController,
                hintText: 'E-Mail',
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon:
                    Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              LoginTextField(
                key: const ValueKey('login_password_field'),
                fieldKey: const ValueKey('login_password'),
                controller: passwordController,
                hintText: 'Passwort',
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
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

              // Forgot Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ForgotPasswordPage();
                      }));
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Passwort vergessen?',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SubmitButton(
                key: const ValueKey('submit_login'),
                onTap: signUserIn,
                text: "Anmelden",
              ),
              const SizedBox(height: 24),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: cs.outlineVariant.withAlpha(153),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ODER WEITER MIT',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: cs.outlineVariant.withAlpha(153),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Social Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SocialLoginButton(
                        key: const ValueKey('social_google'),
                        imagePath: 'images/google.png',
                        text: 'Google',
                        onTap: () => AuthService().signInWithGoogle(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SocialLoginButton(
                        key: const ValueKey('social_apple'),
                        imagePath: 'images/apple.png',
                        text: 'Apple',
                        onTap: () => AuthService().signInWithApple(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Register Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Noch keinen Account?",
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    key: const ValueKey('toggle_register'),
                    onPressed: widget.onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Jetzt registrieren",
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

  signUserIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      showErrorMessage(context, 'Bitte E-Mail und Passwort eingeben');
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (e.code == 'invalid-email' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS' ||
          e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'channel-error') {
        if (mounted) showErrorMessage(context, 'Anmeldedaten falsch!');
      }
    }
  }
}
