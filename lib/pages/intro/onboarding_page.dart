import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tech_knowl_edge_connect/components/buttons/bottom_action_bar.dart';
import 'package:tech_knowl_edge_connect/components/buttons/intro_button.dart';
import 'package:tech_knowl_edge_connect/pages/intro/intro_page_1.dart';
import 'package:tech_knowl_edge_connect/pages/intro/intro_page_2.dart';
import 'package:tech_knowl_edge_connect/pages/intro/intro_page_3.dart';
import 'package:tech_knowl_edge_connect/pages/login/auth_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _controller = PageController();

  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Background PageView
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),

          // Paginator positioned inside the glass panel area
          Positioned(
            bottom: 120 + 32, // Matches the padding inside the glass panel
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  expansionFactor: 3,
                  activeDotColor: cs.primary,
                  dotColor: cs.outlineVariant,
                  spacing: 6,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (onLastPage)
              const SizedBox(width: 80) // Spacer
            else
              IntroButton(
                key: const ValueKey('onboarding_skip'),
                text: "Überspringen",
                onTap: leaveOnBoarding,
              ),
            IntroButton(
              key: const ValueKey('onboarding_next'),
              text: onLastPage ? "Loslegen!" : "Weiter",
              isPrimary: true,
              onTap: () {
                if (onLastPage) {
                  leaveOnBoarding();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void leaveOnBoarding() async {
    setSharedPreferences("welcome", true);
    navigateToAuthPage();
  }

  void setSharedPreferences(String key, bool value) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    myPrefs.setBool(key, value);
  }

  void navigateToAuthPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AuthPage();
        },
      ),
    );
  }
}
