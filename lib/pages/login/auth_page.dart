import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_knowl_edge_connect/pages/intro/onboarding_page.dart';
import 'package:tech_knowl_edge_connect/pages/login/login_or_register_page.dart';
import 'package:tech_knowl_edge_connect/pages/overview_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          default:
            if (snapshot.hasData) {
              return snapshot.data!.getBool("welcome") != null
                  ? Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      body: StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.authStateChanges(),
                        builder: (context, authSnapshot) {
                          switch (authSnapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return const Scaffold(
                                body:
                                    Center(child: CircularProgressIndicator()),
                              );
                            default:
                              if (authSnapshot.hasData) {
                                return const OverviewPage();
                              } else {
                                return const LoginOrRegisterPage();
                              }
                          }
                        },
                      ),
                    )
                  : const OnBoardingPage();
            } else {
              return Scaffold(
                body: Text(snapshot.error.toString()),
              );
            }
        }
      },
    );
  }
}
