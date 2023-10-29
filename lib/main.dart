import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tech_knowl_edge_connect/pages/auth_page.dart';
import 'package:tech_knowl_edge_connect/theme/dark_mode.dart';
import 'package:tech_knowl_edge_connect/theme/light_mode.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TechKnowlEdgeConnect());
}

class TechKnowlEdgeConnect extends StatelessWidget {
  const TechKnowlEdgeConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TechKnowlEdgeConnect',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const AuthPage(),
    );
  }
}
