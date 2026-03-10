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
    required this.onBiteTap,
    required this.onNewBiteTap,
  });

  @override
  State<ConceptBitesSection> createState() => _ConceptBitesSectionState();
}

class _ConceptBitesSectionState extends State<ConceptBitesSection> {
  final ContentService _contentService = ContentService();
  ScrollController? _scrollController;
  bool _hasAutoScrolled = false;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ScrollController();
    if (!_hasAutoScrolled) {
      _hasAutoScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctrl = _scrollController;
        if (ctrl == null || !ctrl.hasClients) return;
        final firstIncomplete =
            widget.conceptBites.indexWhere((ub) => ub.progress < 100);
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

    return FutureBuilder<List<dynamic>>(
      key: ValueKey('concept_${widget.conceptId}'),
      future: Future.wait([
        _contentService
            .getLearningBites(widget.unit.subjectId, widget.categoryId,
                widget.topicId, widget.unit.unitId, widget.conceptId)
            .first,
        FirebaseFirestore.instance
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
            .get()
      ]),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final bitesList = snap.data![0] as List<LearningBite>;
        final conceptDoc =
            snap.data![1] as DocumentSnapshot<Map<String, dynamic>>;
        final conceptName =
            (conceptDoc.data()?['name'] as String?) ?? widget.conceptId;

        final totalProgress = bitesList.fold<int>(
            0, (acc, lb) => acc + (widget.unit.bites[lb.id]?.progress ?? 0));
        final denom = bitesList.length;
        final conceptPercent = denom == 0 ? 0 : (totalProgress / denom).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                child: Text(conceptName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              CircularProgressIndicator(
                value: (conceptPercent.clamp(0, 100)) / 100.0,
                strokeWidth: 5,
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withAlpha(50),
              ),
              const SizedBox(width: 6),
              Text('$conceptPercent%',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface)),
            ]),
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
                          categoryId: widget.categoryId,
                          topicId: widget.topicId,
                          conceptId: widget.conceptId));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
