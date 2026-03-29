import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/components/home/bite_cards.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

/// Displays the latest AI-tech journey for a unit as a horizontal bite list
/// with a progress indicator. This was previously inline in the HomePage build
/// method inside the "ai_generated" / "journey" branch.
class JourneyBitesSection extends StatefulWidget {
  final UnitProgress unit;
  final String journeyId;
  final void Function(UnitProgress unit, UnitBiteProgress bite) onBiteTap;
  final void Function(UnitProgress unit, LearningBite lb,
      {required String journeyId}) onNewBiteTap;

  const JourneyBitesSection({
    super.key,
    required this.unit,
    required this.journeyId,
    required this.onBiteTap,
    required this.onNewBiteTap,
  });

  @override
  State<JourneyBitesSection> createState() => _JourneyBitesSectionState();
}

class _JourneyBitesSectionState extends State<JourneyBitesSection> {
  late ScrollController _scrollController;
  bool _hasAutoScrolled = false;

  // Constants to match bite_cards.dart dimensions
  static const double _cardWidth = 150.0;
  static const double _cardMargin = 8.0;
  static const double _totalStep = _cardWidth + _cardMargin;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningBite>>(
      key: ValueKey('journey_${widget.journeyId}'),
      stream: FirebaseFirestore.instance
          .collection('ai_tech_journeys')
          .doc(widget.journeyId)
          .collection('learning_bites')
          .orderBy('createdAt')
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => LearningBite.fromMap(d.data(), d.id))
              .toList()),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final bitesList = snap.data!;
        if (bitesList.isEmpty) return const SizedBox.shrink();

        final totalProgress = bitesList.fold<int>(
            0, (acc, lb) => acc + (widget.unit.bites[lb.id]?.progress ?? 0));
        final denom = bitesList.length;
        final journeyPercent = denom == 0 ? 0 : (totalProgress / denom).round();

        if (!_hasAutoScrolled && bitesList.isNotEmpty) {
          _hasAutoScrolled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients) return;

            final firstIncomplete = bitesList.indexWhere(
                (lb) => (widget.unit.bites[lb.id]?.progress ?? 0) < 100);

            final idx = firstIncomplete == -1 ? 0 : firstIncomplete;

            final target = (idx * _totalStep)
                .clamp(0.0, _scrollController.position.maxScrollExtent);

            _scrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('ai_tech_journeys')
              .doc(widget.journeyId)
              .snapshots(),
          builder: (context, journeySnap) {
            final journeyDocData = journeySnap.data?.data();
            String journeyName = widget.journeyId;
            if (journeyDocData != null) {
              if (journeyDocData['goal'] is String &&
                  (journeyDocData['goal'] as String).isNotEmpty) {
                journeyName = journeyDocData['goal'] as String;
              } else if (journeyDocData['context'] is String &&
                  (journeyDocData['context'] as String).isNotEmpty) {
                journeyName = journeyDocData['context'] as String;
              } else if (journeyDocData['name'] is String &&
                  (journeyDocData['name'] as String).isNotEmpty) {
                journeyName = journeyDocData['name'] as String;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(journeyName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                    CircularProgressIndicator(
                      value: (journeyPercent.clamp(0, 100)) / 100.0,
                      strokeWidth: 4,
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      backgroundColor:
                          Theme.of(context).colorScheme.primary.withAlpha(50),
                    ),
                    const SizedBox(width: 8),
                    Text('$journeyPercent%',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: bitesList.length,
                    itemBuilder: (context, j) {
                      final lb = bitesList[j];
                      final up = widget.unit.bites[lb.id];

                      return Padding(
                        padding: const EdgeInsets.only(right: _cardMargin),
                        child: SizedBox(
                          width: _cardWidth,
                          child: up != null
                              ? UnitBiteCard(
                                  bite: up,
                                  authoritativeTitle: lb.name,
                                  onTap: () =>
                                      widget.onBiteTap(widget.unit, up))
                              : NewBiteCard(
                                  title: lb.name,
                                  onTap: () => widget.onNewBiteTap(
                                      widget.unit, lb,
                                      journeyId: widget.journeyId)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
