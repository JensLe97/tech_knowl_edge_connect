import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite_type.dart';

Map<String, List<Widget>> data = const {
  "Hilberts Hotel": [
    Text(
        "Hilberts Hotel ist ein hypothetisches Hotel mit unendlich vielen Zimmern, "
        "das von dem deutschen Mathematiker David Hilbert als Gedankenexperiment vorgestellt wurde. "
        "Es zeigt, wie man mit unendlichen Mengen umgehen kann und welche Paradoxien dabei auftreten können. "
        "Zum Beispiel, wenn das Hotel voll belegt ist und ein neuer Gast ankommt, "
        "kann der Hotelmanager alle Gäste bitten, in das nächste Zimmer zu ziehen (Gast in Zimmer 1 zieht in Zimmer 2, Gast in Zimmer 2 zieht in Zimmer 3, usw.), "
        "sodass Zimmer 1 frei wird. "),
    Text(
        "Dies zeigt, dass man trotz voller Belegung immer noch Platz für einen weiteren Gast schaffen kann. "
        "Ein weiteres Beispiel ist, wenn unendlich viele neue Gäste ankommen. "
        "Der Hotelmanager kann alle Gäste bitten, in das Zimmer mit der doppelten Nummer zu ziehen (Gast in Zimmer 1 zieht in Zimmer 2, Gast in Zimmer 2 zieht in Zimmer 4, usw.), "
        "sodass alle ungeraden Zimmer frei werden und Platz für die neuen Gäste schaffen. "),
  ],
  "Unendlichkeitsparadoxon": [
    Text(
        "Das Unendlichkeitsparadoxon, auch bekannt als das Paradoxon der Unendlichkeit, "
        "bezieht sich auf verschiedene logische und mathematische Paradoxa, die auftreten, "
        "wenn man versucht, das Konzept der Unendlichkeit zu verstehen oder anzuwenden. "
        "Diese Paradoxa zeigen, dass unsere alltägliche Intuition oft nicht ausreicht, "
        "um die Konzepte der Unendlichkeit vollständig zu verstehen."),
  ]
};

List<LearningBite> infinityLearningBites = [
  LearningBite(
      name: "Hilberts Hotel",
      type: LearningBiteType.text,
      data: data["Hilberts Hotel"]!,
      iconData: FontAwesomeIcons.hotel),
  LearningBite(
      name: "Unendlichkeitsparadoxon",
      type: LearningBiteType.video,
      data: data["Unendlichkeitsparadoxon"]!,
      iconData: FontAwesomeIcons.infinity),
];
