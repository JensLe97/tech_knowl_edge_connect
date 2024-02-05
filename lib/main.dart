import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_page.dart';
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'TechKnowlEdgeConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          background: Colors.grey.shade100,
          primary: Colors.grey.shade200,
          secondary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade700,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeDelta: 3,
              bodyColor: Colors.grey[850],
              displayColor: Colors.black,
            ),
        primarySwatch: Colors.blueGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade700,
          elevation: 0,
        ),
        bottomSheetTheme:
            const BottomSheetThemeData(backgroundColor: Colors.transparent),
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            background: Colors.grey.shade900,
            primary: Colors.grey.shade800,
            secondary: Colors.grey.shade700,
            inversePrimary: Colors.grey.shade800,
          ),
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeDelta: 3,
                bodyColor: Colors.grey[300],
                displayColor: Colors.white,
              ),
          primarySwatch: Colors.indigo,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade800,
            elevation: 0,
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
          )),
      home: const AuthPage(),
    );
  }
}
