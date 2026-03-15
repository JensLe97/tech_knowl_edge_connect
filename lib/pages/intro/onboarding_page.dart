import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    onLastPage = (index == 2);
                  });
                },
                children: const [
                  SingleChildScrollView(
                    child: IntroPage1(),
                  ),
                  SingleChildScrollView(
                    child: IntroPage2(),
                  ),
                  SingleChildScrollView(
                    child: IntroPage3(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 16.0, bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  onLastPage
                      ? const SizedBox(
                          height: 20,
                          width: 130,
                        )
                      : IntroButton(
                          text: "Überspringen",
                          onTap: () {
                            leaveOnBoarding();
                          },
                        ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                        expansionFactor: 2,
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: Theme.of(context).colorScheme.secondary,
                        spacing: 10,
                        dotHeight: 20,
                        dotWidth: 20),
                  ),
                  onLastPage
                      ? IntroButton(
                          text: "Loslegen!",
                          onTap: () {
                            leaveOnBoarding();
                          },
                        )
                      : IntroButton(
                          text: "Weiter",
                          onTap: () {
                            _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                        ),
                ],
              ),
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
