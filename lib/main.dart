import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_page.dart';
import 'package:tech_knowl_edge_connect/theme.dart';

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
  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } else {
    // ReCaptcha V3 public site key
    const siteKey = '6LfiidArAAAAAOr-wo5IEfX_FqSL4bzLBb4ugZdI';
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(siteKey),
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
    );
  }
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
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
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
