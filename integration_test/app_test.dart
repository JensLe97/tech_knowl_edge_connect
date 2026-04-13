import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tech_knowl_edge_connect/firebase_options.dart';

import 'package:tech_knowl_edge_connect/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture App Screenshots', (WidgetTester tester) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        debugPrint('Signed out successfully before starting the app.');
      } else {
        debugPrint('No user was signed in before starting the app.');
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }

    app.main();
    // Track whether we've converted the Android Flutter surface already.
    bool androidSurfaceConverted = false;

    const String deviceName =
        String.fromEnvironment('DEVICE_NAME', defaultValue: '');
    // Test credentials passed via --dart-define=TEST_EMAIL=... --dart-define=TEST_PASS=...
    const String testEmail =
        String.fromEnvironment('TEST_EMAIL', defaultValue: '');
    const String testPass =
        String.fromEnvironment('TEST_PASS', defaultValue: '');

    Future<void> captureScreen(String name,
        {bool settle = false, int preDelaySeconds = 0}) async {
      if (preDelaySeconds > 0) {
        await tester.pump(Duration(seconds: preDelaySeconds));
      }
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump(const Duration(seconds: 1));
      }
      // Platform-specific handling and folder prefixing for screenshots
      String platformFolder;
      if (kIsWeb) {
        platformFolder = 'web';
      } else if (Platform.isAndroid) {
        platformFolder = 'android';
      } else if (Platform.isIOS) {
        platformFolder = 'ios';
      } else if (Platform.isMacOS) {
        platformFolder = 'macos';
      } else if (Platform.isLinux) {
        platformFolder = 'linux';
      } else if (Platform.isWindows) {
        platformFolder = 'windows';
      } else {
        platformFolder = 'other';
      }

      if (!kIsWeb && Platform.isAndroid && !androidSurfaceConverted) {
        await binding.convertFlutterSurfaceToImage();
        androidSurfaceConverted = true;
        if (settle) {
          await tester.pumpAndSettle();
        } else {
          await tester.pump(const Duration(seconds: 1));
        }
      }

      String deviceFolder = '';
      if (deviceName.isNotEmpty) {
        var sanitized = deviceName.replaceAll(RegExp(r"[^0-9A-Za-z _-]"), '');
        sanitized = sanitized.replaceAll(' ', '_').toLowerCase();
        deviceFolder = '$sanitized/';
      }

      await binding.takeScreenshot('$platformFolder/$deviceFolder$name');
    }

    Future<void> safePageBack(WidgetTester tester) async {
      final Finder backButton = find.byType(BackButton);

      if (backButton.evaluate().isNotEmpty) {
        // If a standard Material BackButton exists, tap it
        await tester.tap(backButton);
      } else {
        // Fallback: Programmatically pop the current route using the root Navigator
        final BuildContext context =
            tester.element(find.byType(Scaffold).first);
        Navigator.of(context).pop();
      }

      // Always wait for the transition animation to finish
      await tester.pumpAndSettle();
    }

    // 1. Replace pumpAndSettle with a hard delay to bypass infinite animations
    // Wait for 3 seconds to let the app load
    await tester.pump(const Duration(seconds: 3));

    // Wait for any of the app entry screens to appear (onboarding -> login -> home)
    final onboardingFinder = find.byKey(const ValueKey('onboarding_skip'));
    final loginFinder = find.byKey(const ValueKey('login_email_field'));
    final overviewFinder = find.byKey(const ValueKey('tab_home'));

    // initial poll for presence of any of these screens (up to 10s)
    for (int i = 0; i < 20; i++) {
      if (onboardingFinder.evaluate().isNotEmpty ||
          loginFinder.evaluate().isNotEmpty ||
          overviewFinder.evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 1) Onboarding: capture and attempt to leave (so we can reach login)
    if (onboardingFinder.evaluate().isNotEmpty) {
      await captureScreen('onboarding', settle: false, preDelaySeconds: 1);

      // Prefer actions in this order: skip, next. Try up to N attempts.
      final actionKeys = <Finder>[
        find.byKey(const ValueKey('onboarding_skip')),
        find.byKey(const ValueKey('onboarding_next')),
      ];

      for (int attempt = 0; attempt < 5; attempt++) {
        bool didTap = false;
        for (final key in actionKeys) {
          if (key.evaluate().isNotEmpty) {
            try {
              await tester.ensureVisible(key);
            } catch (_) {}
            await tester.pump(const Duration(milliseconds: 200));
            try {
              await tester.tap(key, warnIfMissed: false);
              didTap = true;
            } catch (_) {}
            break; // prefer first available action
          }
        }
        if (!didTap) break; // nothing to tap -> exit attempts
        await tester.pump(const Duration(milliseconds: 500));
      }

      // allow navigation to settle and poll for next screens
      for (int i = 0; i < 20; i++) {
        if (loginFinder.evaluate().isNotEmpty ||
            overviewFinder.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // 2) Login: capture if present
    if (loginFinder.evaluate().isNotEmpty) {
      await captureScreen('login_screen', settle: false, preDelaySeconds: 1);
      // If TEST_EMAIL/TEST_PASS are provided, fill the form and submit
      if (testEmail.isNotEmpty && testPass.isNotEmpty) {
        final emailField = find.byKey(const ValueKey('login_email_field'));
        final passField = find.byKey(const ValueKey('login_password_field'));
        final submitBtn = find.byKey(const ValueKey('submit_login'));

        if (emailField.evaluate().isNotEmpty) {
          try {
            await tester.ensureVisible(emailField);
          } catch (_) {}
          await tester.pump(const Duration(milliseconds: 200));
          await tester.enterText(emailField, testEmail);
        }

        if (passField.evaluate().isNotEmpty) {
          try {
            await tester.ensureVisible(passField);
          } catch (_) {}
          await tester.pump(const Duration(milliseconds: 200));
          await tester.enterText(passField, testPass);
        }

        await tester.pump(const Duration(milliseconds: 300));

        if (submitBtn.evaluate().isNotEmpty) {
          try {
            await tester.ensureVisible(submitBtn);
          } catch (_) {}
          await tester.pump(const Duration(milliseconds: 200));
          try {
            await tester.tap(submitBtn, warnIfMissed: false);
          } catch (_) {}
        }
      }

      // after showing login (and possibly submitting), wait for overview
      for (int i = 0; i < 40; i++) {
        if (overviewFinder.evaluate().isNotEmpty) break;
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    // 3) Home/Overview: capture if present (either was present initially or appeared later)
    final hasOverview = overviewFinder.evaluate().isNotEmpty;
    if (hasOverview) {
      await tester.pumpAndSettle();
      await captureScreen('home_screen', settle: true, preDelaySeconds: 2);
    }

    // Navigate tabs and capture screens if overview is present
    if (!hasOverview) return;

    final feedTab = find.byKey(const ValueKey('tab_feed'));
    final chatsTab = find.byKey(const ValueKey('tab_chats'));
    final searchTab = find.byKey(const ValueKey('tab_search'));

    if (feedTab.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(feedTab);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 200));
      try {
        await tester.tap(feedTab, warnIfMissed: false);
      } catch (_) {}
      await captureScreen('feed_screen', settle: true, preDelaySeconds: 0);
    }

    if (chatsTab.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(chatsTab);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 200));
      try {
        await tester.tap(chatsTab, warnIfMissed: false);
      } catch (_) {}
      await captureScreen('chat_overview_screen',
          settle: true, preDelaySeconds: 0);

      final chatFinder = find.text('Lilly@Jens');
      if (chatFinder.evaluate().isNotEmpty) {
        try {
          await tester.ensureVisible(chatFinder);
        } catch (_) {}
        await tester.pump(const Duration(milliseconds: 200));
        try {
          await tester.tap(chatFinder, warnIfMissed: false);
        } catch (_) {}

        await tester.pumpAndSettle();

        await captureScreen('chat_page_screen',
            settle: true, preDelaySeconds: 0);
        // go back one page after viewing chat
        await safePageBack(tester);
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    if (searchTab.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(searchTab);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 200));
      try {
        await tester.tap(searchTab, warnIfMissed: false);
      } catch (_) {}
      await captureScreen('search_screen', settle: true, preDelaySeconds: 0);

      // Tap the tile titled "Der Wasserkreislauf" and capture
      final tileFinder = find.text('Der Wasserkreislauf');
      if (tileFinder.evaluate().isNotEmpty) {
        try {
          await tester.ensureVisible(tileFinder);
        } catch (_) {}
        await tester.pump(const Duration(milliseconds: 200));
        try {
          await tester.tap(tileFinder, warnIfMissed: false);
        } catch (_) {}

        await tester.pumpAndSettle();

        await captureScreen('idea_folder_screen',
            settle: true, preDelaySeconds: 0);
      }
    }
    // After viewing 'Der Wasserkreislauf', go back to Search and navigate deeper
    await safePageBack(tester);
    await tester.pump(const Duration(milliseconds: 500));

    if (searchTab.evaluate().isNotEmpty) {
      try {
        await tester.ensureVisible(searchTab);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 200));
      try {
        await tester.tap(searchTab, warnIfMissed: false);
      } catch (_) {}
      await tester.pump(const Duration(milliseconds: 500));

      // Tap 'Python lernen' first, capture, then go back
      final pythonFinder = find.text('Python lernen');
      if (pythonFinder.evaluate().isNotEmpty) {
        try {
          await tester.ensureVisible(pythonFinder);
        } catch (_) {}
        await tester.pump(const Duration(milliseconds: 200));
        try {
          await tester.tap(pythonFinder, warnIfMissed: false);
        } catch (_) {}

        await tester.pumpAndSettle();

        await captureScreen('learning_journey_screen',
            settle: true, preDelaySeconds: 0);

        // go back one page
        await safePageBack(tester);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Tap 'Informatik'
      final informatikFinder = find.text('Informatik');
      if (informatikFinder.evaluate().isNotEmpty) {
        try {
          await tester.ensureVisible(informatikFinder);
        } catch (_) {}
        await tester.pump(const Duration(milliseconds: 200));
        try {
          await tester.tap(informatikFinder, warnIfMissed: false);
        } catch (_) {}

        await tester.pumpAndSettle();

        // Tap 'Microsoft Azure'
        final azureFinder = find.text('Microsoft Azure');
        if (azureFinder.evaluate().isNotEmpty) {
          try {
            await tester.ensureVisible(azureFinder);
          } catch (_) {}
          await tester.pump(const Duration(milliseconds: 200));
          try {
            await tester.tap(azureFinder, warnIfMissed: false);
          } catch (_) {}

          await tester.pumpAndSettle();

          // Tap 'Einführung in Storage'
          final storageFinder = find.text('Einführung in Storage');
          if (storageFinder.evaluate().isNotEmpty) {
            try {
              await tester.ensureVisible(storageFinder);
            } catch (_) {}
            await tester.pump(const Duration(milliseconds: 200));
            try {
              await tester.tap(storageFinder, warnIfMissed: false);
            } catch (_) {}

            int pageIndex = 1;
            bool hasWeiterButton = true;

            await tester.pumpAndSettle();

            while (hasWeiterButton) {
              if (pageIndex == 1) {
                await captureScreen('learning_bite_content_screen',
                    settle: true, preDelaySeconds: 0);
              }

              final weiterButton = find.text('Weiter');

              if (weiterButton.evaluate().isNotEmpty) {
                await tester.tap(weiterButton.first);
                await tester.pumpAndSettle();

                pageIndex++;
              } else {
                await captureScreen('single_choice_cloze_screen',
                    settle: true, preDelaySeconds: 0);
                hasWeiterButton = false;
              }
            }
            // Tap 'Files' and capture its screen
            final filesFinder = find.text('Files');
            if (filesFinder.evaluate().isNotEmpty) {
              try {
                await tester.ensureVisible(filesFinder);
              } catch (_) {}
              await tester.pump(const Duration(milliseconds: 200));
              try {
                await tester.tap(filesFinder, warnIfMissed: false);
              } catch (_) {}

              await tester.pumpAndSettle();

              await captureScreen('free_text_cloze_screen',
                  settle: true, preDelaySeconds: 2);
            }
          }
        }
      }
    }
  });
}
