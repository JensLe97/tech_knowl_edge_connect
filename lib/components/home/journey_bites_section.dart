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
  ScrollController? _scrollController;
  bool _hasAutoScrolled = false;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      key: ValueKey('journey_${widget.journeyId}'),
      future: _fetchJourneyData(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final data = snap.data!;
        final bitesList = data[0] as List<LearningBite>;
        final journeyName = data[1] as String;
        if (bitesList.isEmpty) return const SizedBox.shrink();

        final totalProgress = bitesList.fold<int>(
            0, (acc, lb) => acc + (widget.unit.bites[lb.id]?.progress ?? 0));
        final denom = bitesList.length;
        final journeyPercent = denom == 0 ? 0 : (totalProgress / denom).round();

        _scrollController ??= ScrollController();
        if (!_hasAutoScrolled) {
          _hasAutoScrolled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctrl = _scrollController;
            if (ctrl == null || !ctrl.hasClients) return;
            final firstIncomplete = bitesList.indexWhere(
                (lb) => (widget.unit.bites[lb.id]?.progress ?? 0) < 100);
            final idx = firstIncomplete == -1 ? 0 : firstIncomplete;
            const tileWidth = 160.0;
            final target =
                (idx * tileWidth).clamp(0.0, ctrl.position.maxScrollExtent);
            try {
              ctrl.animateTo(target,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            } catch (_) {}
          });
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
                  strokeWidth: 5,
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(50),
                ),
                const SizedBox(width: 6),
                Text('$journeyPercent%',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 110,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: bitesList.length,
                itemBuilder: (context, j) {
                  final lb = bitesList[j];
                  final up = widget.unit.bites[lb.id];
                  if (up != null) {
                    return UnitBiteCard(
                        bite: up,
                        onTap: () => widget.onBiteTap(widget.unit, up));
                  }
                  return NewBiteCard(
                      title: lb.name,
                      onTap: () => widget.onNewBiteTap(widget.unit, lb,
                          journeyId: widget.journeyId));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _fetchJourneyData() async {
    final res = <LearningBite>[];
    String journeyName = 'Lernreise';
    try {
      final lbSnap = await FirebaseFirestore.instance
          .collection('ai_tech_journeys')
          .doc(widget.journeyId)
          .collection('learning_bites')
          .orderBy('createdAt')
          .get();
      for (final d in lbSnap.docs) {
        try {
          res.add(LearningBite.fromMap(d.data(), d.id));
        } catch (_) {}
      }
    } catch (_) {}
    try {
      final journeyDoc = await FirebaseFirestore.instance
          .collection('ai_tech_journeys')
          .doc(widget.journeyId)
          .get();
      if (journeyDoc.exists) {
        final goal =
            journeyDoc.data()?['goal'] ?? journeyDoc.data()?['context'];
        if (goal is String && goal.isNotEmpty) {
          journeyName = goal;
        }
      }
    } catch (_) {}
    return [res, journeyName];
  }
}
