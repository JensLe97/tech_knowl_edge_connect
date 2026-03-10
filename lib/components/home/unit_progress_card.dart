import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/components/home/concept_bites_section.dart';
import 'package:tech_knowl_edge_connect/components/home/journey_bites_section.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

/// A card representing a single Unit the user is currently working on.
/// Shows title, linear progress bar, and either the journey or concept
/// bite list depending on the unit source.
class UnitProgressCard extends StatelessWidget {
  final UnitProgress unit;
  final Color? subjectColor;
  final VoidCallback onOpenUnit;
  final VoidCallback onOpenAiSession;
  final void Function(UnitProgress unit, UnitBiteProgress bite) onBiteTap;
  final void Function(UnitProgress unit, LearningBite lb,
      {required String journeyId}) onJourneyBiteTap;
  final void Function(UnitProgress unit, LearningBite lb,
      {required String categoryId,
      required String topicId,
      required String conceptId}) onContentBiteTap;

  const UnitProgressCard({
    super.key,
    required this.unit,
    this.subjectColor,
    required this.onOpenUnit,
    required this.onOpenAiSession,
    required this.onBiteTap,
    required this.onJourneyBiteTap,
    required this.onContentBiteTap,
  });

  @override
  Widget build(BuildContext context) {
    final bites = unit.bites.values.toList()
      ..sort((a, b) {
        final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return ta.compareTo(tb);
      });

    final isAiUnit = unit.source == 'ai_generated' || unit.source == 'journey';

    return Card(
      color: subjectColor,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(context, isAiUnit),
          const SizedBox(height: 8),
          LinearProgressIndicator(
              value: (unit.progress.clamp(0, 100)) / 100.0,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(50)),
          const SizedBox(height: 12),
          _buildBitesSection(bites, isAiUnit),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAiUnit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Row(children: [
          Text(unit.title.isNotEmpty ? unit.title : 'Lernreise',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          if (!isAiUnit)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Einheit öffnen',
              onPressed: onOpenUnit,
            ),
          if (isAiUnit)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Lernreise öffnen',
              onPressed: onOpenAiSession,
            ),
        ])),
        const SizedBox(width: 8),
        Text('${unit.progress}%'),
      ],
    );
  }

  Widget _buildBitesSection(List<UnitBiteProgress> bites, bool isAiUnit) {
    if (isAiUnit) {
      return _buildJourneySection(bites);
    }
    return _buildConceptSection(bites);
  }

  Widget _buildJourneySection(List<UnitBiteProgress> bites) {
    final Map<String, List<UnitBiteProgress>> journeyGroups = {};
    for (final ub in unit.bites.values) {
      final jid = ub.journeyId ?? unit.unitId;
      journeyGroups.putIfAbsent(jid, () => []).add(ub);
    }
    if (journeyGroups.isEmpty) return const SizedBox.shrink();

    // pick latest-started journey by latest timestamp among its bites
    String? latestJourneyId = journeyGroups.keys.first;
    int latestTs = -1;
    for (final entry in journeyGroups.entries) {
      for (final ub in entry.value) {
        final ts = ub.createdAt?.millisecondsSinceEpoch ??
            ub.lastUpdated?.millisecondsSinceEpoch ??
            0;
        if (ts > latestTs) {
          latestTs = ts;
          latestJourneyId = entry.key;
        }
      }
    }
    if (latestJourneyId == null) return const SizedBox.shrink();

    return JourneyBitesSection(
      unit: unit,
      journeyId: latestJourneyId,
      onBiteTap: onBiteTap,
      onNewBiteTap: (u, lb, {required journeyId}) =>
          onJourneyBiteTap(u, lb, journeyId: journeyId),
    );
  }

  Widget _buildConceptSection(List<UnitBiteProgress> bites) {
    final Map<String, List<UnitBiteProgress>> conceptGroups = {};
    for (final b in bites) {
      if (b.conceptId != null && b.categoryId != null && b.topicId != null) {
        conceptGroups.putIfAbsent(b.conceptId!, () => []).add(b);
      }
    }
    if (conceptGroups.isEmpty) return const SizedBox.shrink();

    // Determine the latest started concept
    String? latestConceptId = conceptGroups.keys.first;
    int latestTs = -1;
    for (final b in bites) {
      if (b.conceptId == null) continue;
      final ts = b.createdAt?.millisecondsSinceEpoch ??
          b.lastUpdated?.millisecondsSinceEpoch ??
          0;
      if (ts > latestTs) {
        latestTs = ts;
        latestConceptId = b.conceptId;
      }
    }
    if (latestConceptId == null) return const SizedBox.shrink();
    final entry = conceptGroups[latestConceptId];
    if (entry == null || entry.isEmpty) return const SizedBox.shrink();

    final sample = entry.first;

    return ConceptBitesSection(
      unit: unit,
      conceptId: latestConceptId,
      categoryId: sample.categoryId!,
      topicId: sample.topicId!,
      conceptBites: entry,
      onBiteTap: onBiteTap,
      onNewBiteTap: (u, lb,
              {required categoryId, required topicId, required conceptId}) =>
          onContentBiteTap(u, lb,
              categoryId: categoryId, topicId: topicId, conceptId: conceptId),
    );
  }
}
