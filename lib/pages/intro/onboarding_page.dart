import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tech_knowl_edge_connect/components/intro_button.dart';
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
              physics: NeverScrollableScrollPhysics(),
              child: IntroPage1(),
            ),
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: IntroPage2(),
            ),
            SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: IntroPage3(),
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 60),
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
                      leaveOnBording();
                    },
                  ),
            SmoothPageIndicator(
              controller: _controller,
              count: 3,
              effect: ExpandingDotsEffect(
                  activeDotColor: Theme.of(context).colorScheme.inversePrimary,
                  dotColor: Theme.of(context).colorScheme.secondary,
                  spacing: 10,
                  dotHeight: 20,
                  dotWidth: 20),
            ),
            onLastPage
                ? IntroButton(
                    text: "Loslegen!",
                    onTap: () {
                      leaveOnBording();
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
    );
  }

  void leaveOnBording() async {
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
