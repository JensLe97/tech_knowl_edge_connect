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
    final cs = Theme.of(context).colorScheme;

    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final textStyle = TextStyle(
      fontSize: 12,
      color: cs.onSurfaceVariant,
      height: 1.5,
    );

    final linkStyle = TextStyle(
      fontSize: 12,
      color: cs.primary,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text.rich(
        TextSpan(
          style: textStyle,
          children: [
            const TextSpan(
              text: "Mit dem Benutzen der App bestätigst du, dass du unsere",
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: TextButton(
                onPressed: () => openUrl(termsAndConditions),
                style: buttonStyle,
                child: Text("AGB", style: linkStyle),
              ),
            ),
            const TextSpan(
              text: "und",
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: TextButton(
                onPressed: () => openUrl(privacyPolicy),
                style: buttonStyle,
                child: Text("Datenschutzbestimmungen", style: linkStyle),
              ),
            ),
            const TextSpan(
              text: "gelesen und akzeptiert hast.",
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
