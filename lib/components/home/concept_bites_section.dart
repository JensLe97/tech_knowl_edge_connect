import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/components/home/bite_cards.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

/// Displays the latest concept for a content-based unit as a horizontal bite
/// list with a progress indicator.
class ConceptBitesSection extends StatefulWidget {
  final UnitProgress unit;
  final String conceptId;
  final String categoryId;
  final String topicId;
  final List<UnitBiteProgress> conceptBites;
  final Widget Function(String subtitle, int progress) headerBuilder;
  final void Function(UnitProgress unit, UnitBiteProgress bite) onBiteTap;
  final void Function(UnitProgress unit, LearningBite lb,
      {required String categoryId,
      required String topicId,
      required String conceptId}) onNewBiteTap;

  const ConceptBitesSection({
    super.key,
    required this.unit,
    required this.conceptId,
    required this.categoryId,
    required this.topicId,
    required this.conceptBites,
    required this.headerBuilder,
    required this.onBiteTap,
    required this.onNewBiteTap,
  });

  @override
  State<ConceptBitesSection> createState() => _ConceptBitesSectionState();
}

class _ConceptBitesSectionState extends State<ConceptBitesSection> {
  final ContentService _contentService = ContentService();
  late ScrollController _scrollController;
  bool _hasAutoScrolled = false;

  // Exact dimensions to match the Card file
  static const double _cardWidth = 160.0;
  static const double _cardMargin = 12.0;
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
      key: ValueKey('concept_${widget.conceptId}'),
      stream: _contentService.getLearningBites(
        widget.unit.subjectId,
        widget.categoryId,
        widget.topicId,
        widget.unit.unitId,
        widget.conceptId,
      ),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.headerBuilder('Lerneinheit', widget.unit.progress),
            ],
          );
        }
        final bitesList = snap.data!;
        if (bitesList.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.headerBuilder('Lerneinheit', widget.unit.progress),
            ],
          );
        }

        final totalProgress = bitesList.fold<int>(
            0, (acc, lb) => acc + (widget.unit.bites[lb.id]?.progress ?? 0));
        final denom = bitesList.length;
        final conceptPercent = denom == 0 ? 0 : (totalProgress / denom).round();

        if (!_hasAutoScrolled) {
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
              .collection('content_subjects')
              .doc(widget.unit.subjectId)
              .collection('categories')
              .doc(widget.categoryId)
              .collection('topics')
              .doc(widget.topicId)
              .collection('units')
              .doc(widget.unit.unitId)
              .collection('concepts')
              .doc(widget.conceptId)
              .snapshots(),
          builder: (context, conceptSnap) {
            final conceptDoc = conceptSnap.data?.data();
            final conceptName =
                (conceptDoc != null && conceptDoc['name'] is String)
                    ? conceptDoc['name'] as String
                    : 'Lerneinheit';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.headerBuilder(conceptName, conceptPercent),
                SizedBox(
                  height: 112,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.only(left: 20.0, right: 8.0),
                    itemCount: bitesList.length,
                    itemBuilder: (context, j) {
                      final lb = bitesList[j];
                      final up = widget.unit.bites[lb.id];

                      return Padding(
                        padding: const EdgeInsets.only(right: _cardMargin),
                        child: up != null
                            ? UnitBiteCard(
                                bite: up,
                                authoritativeTitle: lb.name,
                                onTap: () => widget.onBiteTap(widget.unit, up))
                            : NewBiteCard(
                                title: lb.name,
                                onTap: () => widget.onNewBiteTap(
                                    widget.unit, lb,
                                    categoryId: widget.categoryId,
                                    topicId: widget.topicId,
                                    conceptId: widget.conceptId)),
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
