import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_page.dart';

import 'firebase_options.dart';

/*
  Generation of env.g.dart:
  flutter pub run build_runner clean
  flutter pub run build_runner build --delete-conflicting-outputs
  For GitHub Actions:
  Windows: certutil -encode lib\env\env.g.dart tmp.b64 && findstr /v /c:- tmp.b64 > data.b64
  macOS: openssl base64 -in lib/env/env.g.dart -out data.b64
*/

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
          surface: Colors.grey.shade100,
          primary: Colors.grey.shade200,
          onPrimary: Colors.grey.shade300,
          secondary: Colors.grey.shade400,
          inversePrimary: Colors.grey.shade700,
          onSecondary: Colors.grey.shade800,
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
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Colors.grey[850],
                fontSizeDelta: 3,
              ),
          backgroundColor: Colors.grey.shade100,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.grey.shade600),
          trackColor: WidgetStateProperty.all(Colors.grey.shade400),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          surface: Colors.grey.shade900,
          onPrimary: Colors.grey[850]!,
          primary: Colors.grey.shade800,
          secondary: Colors.grey.shade700,
          inversePrimary: Colors.grey.shade800,
          onSecondary: Colors.grey.shade900,
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
        ),
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: Theme.of(context).textTheme.bodyMedium?.apply(
                color: Colors.grey[300],
                fontSizeDelta: 3,
              ),
          backgroundColor: Colors.grey.shade900,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.grey.shade700),
          trackColor: WidgetStateProperty.all(Colors.grey.shade500),
        ),
      ),
      supportedLocales: const [
        Locale('de'), // German
        Locale('en'), // English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthPage(),
    );
  }
}
