import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/components/home/concept_bites_section.dart';
import 'package:tech_knowl_edge_connect/components/home/journey_bites_section.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

typedef ProgressHeaderBuilder = Widget Function(String subtitle, int progress);

/// A card representing a single Unit the user is currently working on.
/// Shows title, linear progress bar, and either the journey or concept
/// bite list depending on the unit source.
class UnitProgressCard extends StatelessWidget {
  final UnitProgress unit;
  final Color? subjectColor;
  final String? unitTitle;
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
    this.unitTitle,
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAiUnit = unit.source == 'ai_generated' || unit.source == 'journey';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(76),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              _buildBitesSection(context, bites, isAiUnit, colorScheme, theme),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAiUnit,
      ColorScheme colorScheme, ThemeData theme, String subtitle, int progress) {
    final displayTitle = (unitTitle != null && unitTitle!.isNotEmpty)
        ? unitTitle!
        : (isAiUnit ? 'Lernreise' : 'Einheit');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: isAiUnit ? onOpenAiSession : onOpenUnit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '$progress%',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBitesSection(BuildContext context, List<UnitBiteProgress> bites,
      bool isAiUnit, ColorScheme colorScheme, ThemeData theme) {
    Widget headerBuilder(String subtitle, int progress) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
              context, isAiUnit, colorScheme, theme, subtitle, progress),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (progress.clamp(0, 100)) / 100.0,
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (isAiUnit) {
      return _buildJourneySection(bites, headerBuilder);
    }
    return _buildConceptSection(bites, headerBuilder);
  }

  Widget _buildJourneySection(
      List<UnitBiteProgress> bites, ProgressHeaderBuilder headerBuilder) {
    final Map<String, List<UnitBiteProgress>> journeyGroups = {};
    for (final ub in unit.bites.values) {
      final jid = ub.journeyId ?? unit.unitId;
      journeyGroups.putIfAbsent(jid, () => []).add(ub);
    }
    if (journeyGroups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerBuilder('Lernreise', unit.progress),
        ],
      );
    }

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
    if (latestJourneyId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerBuilder('Lernreise', unit.progress),
        ],
      );
    }

    return JourneyBitesSection(
      unit: unit,
      journeyId: latestJourneyId,
      headerBuilder: headerBuilder,
      onBiteTap: onBiteTap,
      onNewBiteTap: (u, lb, {required journeyId}) =>
          onJourneyBiteTap(u, lb, journeyId: journeyId),
    );
  }

  Widget _buildConceptSection(
      List<UnitBiteProgress> bites, ProgressHeaderBuilder headerBuilder) {
    final Map<String, List<UnitBiteProgress>> conceptGroups = {};
    for (final b in bites) {
      if (b.conceptId != null && b.categoryId != null && b.topicId != null) {
        conceptGroups.putIfAbsent(b.conceptId!, () => []).add(b);
      }
    }
    if (conceptGroups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerBuilder('Lerneinheit', unit.progress),
        ],
      );
    }

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
    if (latestConceptId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerBuilder('Lerneinheit', unit.progress),
        ],
      );
    }

    final entry = conceptGroups[latestConceptId];
    if (entry == null || entry.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerBuilder('Lerneinheit', unit.progress),
        ],
      );
    }

    final sample = entry.first;

    return ConceptBitesSection(
      unit: unit,
      conceptId: latestConceptId,
      categoryId: sample.categoryId!,
      topicId: sample.topicId!,
      conceptBites: entry,
      headerBuilder: headerBuilder,
      onBiteTap: onBiteTap,
      onNewBiteTap: (u, lb,
              {required categoryId, required topicId, required conceptId}) =>
          onContentBiteTap(u, lb,
              categoryId: categoryId, topicId: topicId, conceptId: conceptId),
    );
  }
}
