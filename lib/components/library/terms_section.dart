import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditions extends StatelessWidget {
  final String termsAndConditions =
      "https://jenslemke.com/tech-knowl-edge-connect";
  final String privacyPolicy =
      "https://jenslemke.com/tech-knowl-edge-connect#privacy";

  const TermsAndConditions({super.key});

  Future<void> openUrl(String url) async {
    final toLaunch = Uri.parse(url);
    if (!await launchUrl(toLaunch)) {
      throw Exception('Could not launch $toLaunch');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          const Text(
            "Mit dem Benutzen der App bestätigst du, dass du",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(
            width: 4,
          ),
          const Text(
            "unsere",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(
            width: 4,
          ),
          TextButton(
            onPressed: () => openUrl(termsAndConditions),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "AGB",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          const Text(
            "und",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(
            width: 4,
          ),
          TextButton(
            onPressed: () => openUrl(privacyPolicy),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Datenschutzbestimmungen",
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          const Text(
            "gelesen und akzeptiert hast.",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
