import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_management_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/ai_authoring_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/categories_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/concepts_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/content_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/category_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/concept_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/confirm_delete_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/content_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/learning_bite_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/preview_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/subject_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/task_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/topic_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/unit_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/learning_bites_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/pending_approvals_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/subjects_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/tasks_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/topics_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/units_card.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/services/admin_claims_service.dart';
import 'package:tech_knowl_edge_connect/services/admin_functions_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class ContentAdminPage extends StatefulWidget {
  const ContentAdminPage({super.key});

  @override
  State<ContentAdminPage> createState() => _ContentAdminPageState();
}

class _ContentAdminPageState extends State<ContentAdminPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ContentAdminService _adminService = ContentAdminService();
  final AdminClaimsService _claimsService = AdminClaimsService();
  final AdminFunctionsService _functionsService = AdminFunctionsService();
  final AiTechService _aiService = AiTechService();

  String? _statusFilter;

  String? _selectedSubjectId;
  String? _selectedCategoryId;
  String? _selectedTopicId;
  String? _selectedUnitId;
  String? _selectedConceptId;
  String? _selectedLearningBiteId;
  Map<String, dynamic>? _selectedLearningBiteData;
  // Tasks generally don't need a persistent selection state in this view

  late Stream<bool> _adminCheckStream;

  @override
  void initState() {
    super.initState();
    _adminCheckStream = _claimsService.adminChanges();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('Bitte melde dich an, um fortzufahren.'),
        ),
      );
    }

    return StreamBuilder<bool>(
      stream: _adminCheckStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isAdmin = snapshot.data == true;
        if (!isAdmin) {
          return Scaffold(
            appBar: AppBar(title: const Text('Admin Dashboard')),
            body: const Center(
              child: Text('Zugriff verweigert. Admin-Rechte erforderlich.'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Admin Dashboard'),
              ],
            ),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1100;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Genehmigungen'),
                    const SizedBox(height: 12),
                    PendingApprovalsCard(
                      adminService: _adminService,
                      onPreview: (doc) {
                        final pathSegments = doc.reference.path.split('/');
                        // Expected path:
                        // content_subjects/{sId}/categories/{cId}/topics/{tId}/units/{uId}/concepts/{coId}/learning_bites/{lbId}
                        // Segments:
                        // 0: content_subjects
                        // 1: sId
                        // 2: categories
                        // 3: cId
                        // 4: topics
                        // 5: tId
                        // 6: units
                        // 7: uId
                        // 8: concepts
                        // 9: coId
                        // 10: learning_bites
                        // 11: lbId
                        if (pathSegments.length >= 12) {
                          _openPreviewDialog(
                            subjectId: pathSegments[1],
                            categoryId: pathSegments[3],
                            topicId: pathSegments[5],
                            unitId: pathSegments[7],
                            conceptId: pathSegments[9],
                            learningBiteId: doc.id,
                            learningBiteData:
                                doc.data() as Map<String, dynamic>,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Konnte Pfad nicht auflösen. Vorschau nicht möglich.')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Inhaltsverwaltung'),
                        SizedBox(
                          width: 200,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              border: OutlineInputBorder(),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _statusFilter,
                                borderRadius: BorderRadius.circular(12),
                                isDense: true,
                                isExpanded: true,
                                hint: const Text('Alle Inhalte'),
                                items: [
                                  const DropdownMenuItem(
                                      value: null, child: Text('Alle Inhalte')),
                                  ...AdminConstants.statusLabels.entries.map(
                                    (entry) => DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.value),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _statusFilter = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Level 1 & 2: Subjects & Categories
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: SubjectsCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                statusFilter: _statusFilter,
                                onAdd: () =>
                                    _openSubjectDialog(userId: user.uid),
                                onEdit: (id, data) => _openSubjectDialog(
                                    userId: user.uid,
                                    subjectId: id,
                                    existing: data),
                                onSelect: (id) => setState(() {
                                  _selectedSubjectId = id;
                                  _selectedCategoryId = null;
                                  _selectedTopicId = null;
                                  _selectedUnitId = null;
                                  _selectedConceptId = null;
                                  _selectedLearningBiteId = null;
                                  _selectedLearningBiteData = null;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Fach löschen?',
                                    message:
                                        'Möchtest du dieses Fach wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteSubject(
                                          subjectId: id);
                                      if (_selectedSubjectId == id) {
                                        setState(() {
                                          _selectedSubjectId = null;
                                          _selectedCategoryId = null;
                                          _selectedTopicId = null;
                                          _selectedUnitId = null;
                                          _selectedConceptId = null;
                                          _selectedLearningBiteId = null;
                                          _selectedLearningBiteData = null;
                                        });
                                      }
                                    }),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: CategoriesCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                statusFilter: _statusFilter,
                                onAdd: _selectedSubjectId == null
                                    ? null
                                    : () => _openCategoryDialog(
                                        userId: user.uid,
                                        subjectId: _selectedSubjectId!),
                                onEdit: (id, data) => _openCategoryDialog(
                                    userId: user.uid,
                                    subjectId: _selectedSubjectId!,
                                    categoryId: id,
                                    existing: data),
                                onSelect: (id) => setState(() {
                                  _selectedCategoryId = id;
                                  _selectedTopicId = null;
                                  _selectedUnitId = null;
                                  _selectedConceptId = null;
                                  _selectedLearningBiteId = null;
                                  _selectedLearningBiteData = null;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Kategorie löschen?',
                                    message:
                                        'Möchtest du diese Kategorie wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteCategory(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: id);
                                      if (_selectedCategoryId == id) {
                                        setState(() {
                                          _selectedCategoryId = null;
                                          _selectedTopicId = null;
                                          _selectedUnitId = null;
                                          _selectedConceptId = null;
                                          _selectedLearningBiteId = null;
                                          _selectedLearningBiteData = null;
                                        });
                                      }
                                    }),
                              )),
                            ],
                          )
                        : Column(children: [
                            SubjectsCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              statusFilter: _statusFilter,
                              onAdd: () => _openSubjectDialog(userId: user.uid),
                              onEdit: (id, data) => _openSubjectDialog(
                                  userId: user.uid,
                                  subjectId: id,
                                  existing: data),
                              onSelect: (id) => setState(() {
                                _selectedSubjectId = id;
                                _selectedCategoryId = null;
                                _selectedTopicId = null;
                                _selectedUnitId = null;
                                _selectedConceptId = null;
                                _selectedLearningBiteId = null;
                                _selectedLearningBiteData = null;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Fach löschen?',
                                  message:
                                      'Möchtest du dieses Fach wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteSubject(
                                        subjectId: id);
                                    if (_selectedSubjectId == id) {
                                      setState(() {
                                        _selectedSubjectId = null;
                                        _selectedCategoryId = null;
                                        _selectedTopicId = null;
                                        _selectedUnitId = null;
                                        _selectedConceptId = null;
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }
                                  }),
                            ),
                            const SizedBox(height: 12),
                            CategoriesCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              statusFilter: _statusFilter,
                              onAdd: _selectedSubjectId == null
                                  ? null
                                  : () => _openCategoryDialog(
                                      userId: user.uid,
                                      subjectId: _selectedSubjectId!),
                              onEdit: (id, data) => _openCategoryDialog(
                                  userId: user.uid,
                                  subjectId: _selectedSubjectId!,
                                  categoryId: id,
                                  existing: data),
                              onSelect: (id) => setState(() {
                                _selectedCategoryId = id;
                                _selectedTopicId = null;
                                _selectedUnitId = null;
                                _selectedConceptId = null;
                                _selectedLearningBiteId = null;
                                _selectedLearningBiteData = null;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Kategorie löschen?',
                                  message:
                                      'Möchtest du diese Kategorie wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteCategory(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: id);
                                    if (_selectedCategoryId == id) {
                                      setState(() {
                                        _selectedCategoryId = null;
                                        _selectedTopicId = null;
                                        _selectedUnitId = null;
                                        _selectedConceptId = null;
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }
                                  }),
                            ),
                          ]),

                    const SizedBox(height: 12),

                    // Level 3 & 4: Topics & Units
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: TopicsCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                statusFilter: _statusFilter,
                                onAdd: (_selectedSubjectId != null &&
                                        _selectedCategoryId != null)
                                    ? () => _openTopicDialog(
                                        userId: user.uid,
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!)
                                    : null,
                                onEdit: (id, data) => _openTopicDialog(
                                    userId: user.uid,
                                    subjectId: _selectedSubjectId!,
                                    categoryId: _selectedCategoryId!,
                                    topicId: id,
                                    existing: data),
                                onSelect: (id) => setState(() {
                                  _selectedTopicId = id;
                                  _selectedUnitId = null;
                                  _selectedConceptId = null;
                                  _selectedLearningBiteId = null;
                                  _selectedLearningBiteData = null;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Topic löschen?',
                                    message:
                                        'Möchtest du dieses Topic wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteTopic(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: id);
                                      if (_selectedTopicId == id) {
                                        setState(() {
                                          _selectedTopicId = null;
                                          _selectedUnitId = null;
                                          _selectedConceptId = null;
                                          _selectedLearningBiteId = null;
                                          _selectedLearningBiteData = null;
                                        });
                                      }
                                    }),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: UnitsCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                selectedUnitId: _selectedUnitId,
                                statusFilter: _statusFilter,
                                onAdd: (_selectedSubjectId != null &&
                                        _selectedCategoryId != null &&
                                        _selectedTopicId != null)
                                    ? () => _openUnitDialog(
                                        userId: user.uid,
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!)
                                    : null,
                                onEdit: (id, data) => _openUnitDialog(
                                    userId: user.uid,
                                    subjectId: _selectedSubjectId!,
                                    categoryId: _selectedCategoryId!,
                                    topicId: _selectedTopicId!,
                                    unitId: id,
                                    existing: data),
                                onSelect: (id) => setState(() {
                                  _selectedUnitId = id;
                                  _selectedConceptId = null;
                                  _selectedLearningBiteId = null;
                                  _selectedLearningBiteData = null;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Unit löschen?',
                                    message:
                                        'Möchtest du diese Unit wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteUnit(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: _selectedTopicId!,
                                          unitId: id);
                                      if (_selectedUnitId == id) {
                                        setState(() {
                                          _selectedUnitId = null;
                                          _selectedConceptId = null;
                                          _selectedLearningBiteId = null;
                                          _selectedLearningBiteData = null;
                                        });
                                      }
                                    }),
                              )),
                            ],
                          )
                        : Column(children: [
                            TopicsCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              statusFilter: _statusFilter,
                              onAdd: (_selectedSubjectId != null &&
                                      _selectedCategoryId != null)
                                  ? () => _openTopicDialog(
                                      userId: user.uid,
                                      subjectId: _selectedSubjectId!,
                                      categoryId: _selectedCategoryId!)
                                  : null,
                              onEdit: (id, data) => _openTopicDialog(
                                  userId: user.uid,
                                  subjectId: _selectedSubjectId!,
                                  categoryId: _selectedCategoryId!,
                                  topicId: id,
                                  existing: data),
                              onSelect: (id) => setState(() {
                                _selectedTopicId = id;
                                _selectedUnitId = null;
                                _selectedConceptId = null;
                                _selectedLearningBiteId = null;
                                _selectedLearningBiteData = null;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Topic löschen?',
                                  message:
                                      'Möchtest du dieses Topic wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteTopic(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: id);
                                    if (_selectedTopicId == id) {
                                      setState(() {
                                        _selectedTopicId = null;
                                        _selectedUnitId = null;
                                        _selectedConceptId = null;
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }
                                  }),
                            ),
                            const SizedBox(height: 12),
                            UnitsCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              selectedUnitId: _selectedUnitId,
                              statusFilter: _statusFilter,
                              onAdd: (_selectedSubjectId != null &&
                                      _selectedCategoryId != null &&
                                      _selectedTopicId != null)
                                  ? () => _openUnitDialog(
                                      userId: user.uid,
                                      subjectId: _selectedSubjectId!,
                                      categoryId: _selectedCategoryId!,
                                      topicId: _selectedTopicId!)
                                  : null,
                              onEdit: (id, data) => _openUnitDialog(
                                  userId: user.uid,
                                  subjectId: _selectedSubjectId!,
                                  categoryId: _selectedCategoryId!,
                                  topicId: _selectedTopicId!,
                                  unitId: id,
                                  existing: data),
                              onSelect: (id) => setState(() {
                                _selectedUnitId = id;
                                _selectedConceptId = null;
                                _selectedLearningBiteId = null;
                                _selectedLearningBiteData = null;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Unit löschen?',
                                  message:
                                      'Möchtest du diese Unit wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteUnit(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: id);
                                    if (_selectedUnitId == id) {
                                      setState(() {
                                        _selectedUnitId = null;
                                        _selectedConceptId = null;
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }
                                  }),
                            ),
                          ]),

                    const SizedBox(height: 12),

                    // Level 5 & 6: Concepts & Learning Bites
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: ConceptsCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                selectedUnitId: _selectedUnitId,
                                selectedConceptId: _selectedConceptId,
                                statusFilter: _statusFilter,
                                onAdd: (_selectedSubjectId != null &&
                                        _selectedCategoryId != null &&
                                        _selectedTopicId != null &&
                                        _selectedUnitId != null)
                                    ? () => _openConceptDialog(
                                        userId: user.uid,
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!)
                                    : null,
                                onEdit: (id, data) => _openConceptDialog(
                                    userId: user.uid,
                                    subjectId: _selectedSubjectId!,
                                    categoryId: _selectedCategoryId!,
                                    topicId: _selectedTopicId!,
                                    unitId: _selectedUnitId!,
                                    conceptId: id,
                                    existing: data),
                                onSelect: (id) => setState(() {
                                  _selectedConceptId = id;
                                  _selectedLearningBiteId = null;
                                  _selectedLearningBiteData = null;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Konzept löschen?',
                                    message:
                                        'Möchtest du dieses Konzept wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteConcept(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: _selectedTopicId!,
                                          unitId: _selectedUnitId!,
                                          conceptId: id);
                                      if (_selectedConceptId == id) {
                                        setState(() {
                                          _selectedConceptId = null;
                                          _selectedLearningBiteId = null;
                                          _selectedLearningBiteData = null;
                                        });
                                      }
                                    }),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: LearningBitesCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                selectedUnitId: _selectedUnitId,
                                selectedConceptId: _selectedConceptId,
                                selectedLearningBiteId: _selectedLearningBiteId,
                                statusFilter: _statusFilter,
                                onAdd: (_selectedSubjectId != null &&
                                        _selectedCategoryId != null &&
                                        _selectedTopicId != null &&
                                        _selectedUnitId != null &&
                                        _selectedConceptId != null)
                                    ? () => _openLearningBiteDialog(
                                        userId: user.uid,
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!,
                                        conceptId: _selectedConceptId!)
                                    : null,
                                onEdit: (id, data) => _openLearningBiteDialog(
                                    userId: user.uid,
                                    subjectId: _selectedSubjectId!,
                                    categoryId: _selectedCategoryId!,
                                    topicId: _selectedTopicId!,
                                    unitId: _selectedUnitId!,
                                    conceptId: _selectedConceptId!,
                                    learningBiteId: id,
                                    existing: data),
                                onSelect: (id, data) => setState(() {
                                  _selectedLearningBiteId = id;
                                  _selectedLearningBiteData = data;
                                }),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Learning Bite löschen?',
                                    message:
                                        'Möchtest du dieses Learning Bite unwiderruflich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteLearningBite(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: _selectedTopicId!,
                                          unitId: _selectedUnitId!,
                                          conceptId: _selectedConceptId!,
                                          learningBiteId: id);
                                      setState(() {
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }),
                                onPreview: (id, data) => _openPreviewDialog(
                                    subjectId: _selectedSubjectId!,
                                    categoryId: _selectedCategoryId!,
                                    topicId: _selectedTopicId!,
                                    unitId: _selectedUnitId!,
                                    conceptId: _selectedConceptId!,
                                    learningBiteId: id,
                                    learningBiteData: data),
                              )),
                            ],
                          )
                        : Column(children: [
                            ConceptsCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              selectedUnitId: _selectedUnitId,
                              selectedConceptId: _selectedConceptId,
                              statusFilter: _statusFilter,
                              onAdd: (_selectedSubjectId != null &&
                                      _selectedCategoryId != null &&
                                      _selectedTopicId != null &&
                                      _selectedUnitId != null)
                                  ? () => _openConceptDialog(
                                      userId: user.uid,
                                      subjectId: _selectedSubjectId!,
                                      categoryId: _selectedCategoryId!,
                                      topicId: _selectedTopicId!,
                                      unitId: _selectedUnitId!)
                                  : null,
                              onEdit: (id, data) => _openConceptDialog(
                                  userId: user.uid,
                                  subjectId: _selectedSubjectId!,
                                  categoryId: _selectedCategoryId!,
                                  topicId: _selectedTopicId!,
                                  unitId: _selectedUnitId!,
                                  conceptId: id,
                                  existing: data),
                              onSelect: (id) => setState(() {
                                _selectedConceptId = id;
                                _selectedLearningBiteId = null;
                                _selectedLearningBiteData = null;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Konzept löschen?',
                                  message:
                                      'Möchtest du dieses Konzept wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteConcept(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!,
                                        conceptId: id);
                                    if (_selectedConceptId == id) {
                                      setState(() {
                                        _selectedConceptId = null;
                                        _selectedLearningBiteId = null;
                                        _selectedLearningBiteData = null;
                                      });
                                    }
                                  }),
                            ),
                            const SizedBox(height: 12),
                            LearningBitesCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              selectedUnitId: _selectedUnitId,
                              selectedConceptId: _selectedConceptId,
                              selectedLearningBiteId: _selectedLearningBiteId,
                              statusFilter: _statusFilter,
                              onAdd: (_selectedSubjectId != null &&
                                      _selectedCategoryId != null &&
                                      _selectedTopicId != null &&
                                      _selectedUnitId != null &&
                                      _selectedConceptId != null)
                                  ? () => _openLearningBiteDialog(
                                      userId: user.uid,
                                      subjectId: _selectedSubjectId!,
                                      categoryId: _selectedCategoryId!,
                                      topicId: _selectedTopicId!,
                                      unitId: _selectedUnitId!,
                                      conceptId: _selectedConceptId!)
                                  : null,
                              onEdit: (id, data) => _openLearningBiteDialog(
                                  userId: user.uid,
                                  subjectId: _selectedSubjectId!,
                                  categoryId: _selectedCategoryId!,
                                  topicId: _selectedTopicId!,
                                  unitId: _selectedUnitId!,
                                  conceptId: _selectedConceptId!,
                                  learningBiteId: id,
                                  existing: data),
                              onSelect: (id, data) => setState(() {
                                _selectedLearningBiteId = id;
                                _selectedLearningBiteData = data;
                              }),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Learning Bite löschen?',
                                  message:
                                      'Möchtest du dieses Learning Bite unwiderruflich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteLearningBite(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!,
                                        conceptId: _selectedConceptId!,
                                        learningBiteId: id);
                                    setState(() {
                                      _selectedLearningBiteId = null;
                                      _selectedLearningBiteData = null;
                                    });
                                  }),
                              onPreview: (id, data) => _openPreviewDialog(
                                  subjectId: _selectedSubjectId!,
                                  categoryId: _selectedCategoryId!,
                                  topicId: _selectedTopicId!,
                                  unitId: _selectedUnitId!,
                                  conceptId: _selectedConceptId!,
                                  learningBiteId: id,
                                  learningBiteData: data),
                            ),
                          ]),

                    const SizedBox(height: 12),

                    // Content & Tasks
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: ContentCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                selectedUnitId: _selectedUnitId,
                                selectedConceptId: _selectedConceptId,
                                selectedLearningBiteId: _selectedLearningBiteId,
                                onAdd: () => _openContentDialog(),
                                onEdit: (index, content, allContent) =>
                                    _openContentDialog(
                                        index: index,
                                        initialContent: content,
                                        allContent: allContent),
                                onDelete: (index, allContent) => _confirmDelete(
                                    title: 'Inhalt löschen?',
                                    message:
                                        'Möchtest du diesen Inhaltsteil wirklich löschen?',
                                    onConfirm: () async {
                                      allContent.removeAt(index);
                                      await _adminService.updateLearningBite(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: _selectedTopicId!,
                                          unitId: _selectedUnitId!,
                                          conceptId: _selectedConceptId!,
                                          learningBiteId:
                                              _selectedLearningBiteId!,
                                          data: {'content': allContent});
                                    }),
                              )),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TasksCard(
                                adminService: _adminService,
                                selectedSubjectId: _selectedSubjectId,
                                selectedCategoryId: _selectedCategoryId,
                                selectedTopicId: _selectedTopicId,
                                selectedUnitId: _selectedUnitId,
                                selectedConceptId: _selectedConceptId,
                                selectedLearningBiteId: _selectedLearningBiteId,
                                onAdd: (_selectedSubjectId != null &&
                                        _selectedCategoryId != null &&
                                        _selectedTopicId != null &&
                                        _selectedUnitId != null &&
                                        _selectedConceptId != null &&
                                        _selectedLearningBiteId != null)
                                    ? () => _openTaskDialog()
                                    : null,
                                onEdit: (id, data) =>
                                    _openTaskDialog(taskId: id, existing: data),
                                onDelete: (id) => _confirmDelete(
                                    title: 'Aufgabe löschen?',
                                    message:
                                        'Möchtest du diese Aufgabe wirklich löschen?',
                                    onConfirm: () async {
                                      await _adminService.deleteTask(
                                          subjectId: _selectedSubjectId!,
                                          categoryId: _selectedCategoryId!,
                                          topicId: _selectedTopicId!,
                                          unitId: _selectedUnitId!,
                                          conceptId: _selectedConceptId!,
                                          learningBiteId:
                                              _selectedLearningBiteId!,
                                          taskId: id);
                                    }),
                              )),
                            ],
                          )
                        : Column(children: [
                            ContentCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              selectedUnitId: _selectedUnitId,
                              selectedConceptId: _selectedConceptId,
                              selectedLearningBiteId: _selectedLearningBiteId,
                              onAdd: () => _openContentDialog(),
                              onEdit: (index, content, allContent) =>
                                  _openContentDialog(
                                      index: index,
                                      initialContent: content,
                                      allContent: allContent),
                              onDelete: (index, allContent) => _confirmDelete(
                                  title: 'Inhalt löschen?',
                                  message:
                                      'Möchtest du diesen Inhaltsteil wirklich löschen?',
                                  onConfirm: () async {
                                    allContent.removeAt(index);
                                    await _adminService.updateLearningBite(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!,
                                        conceptId: _selectedConceptId!,
                                        learningBiteId:
                                            _selectedLearningBiteId!,
                                        data: {'content': allContent});
                                  }),
                            ),
                            const SizedBox(height: 12),
                            TasksCard(
                              adminService: _adminService,
                              selectedSubjectId: _selectedSubjectId,
                              selectedCategoryId: _selectedCategoryId,
                              selectedTopicId: _selectedTopicId,
                              selectedUnitId: _selectedUnitId,
                              selectedConceptId: _selectedConceptId,
                              selectedLearningBiteId: _selectedLearningBiteId,
                              onAdd: (_selectedSubjectId != null &&
                                      _selectedCategoryId != null &&
                                      _selectedTopicId != null &&
                                      _selectedUnitId != null &&
                                      _selectedConceptId != null &&
                                      _selectedLearningBiteId != null)
                                  ? () => _openTaskDialog()
                                  : null,
                              onEdit: (id, data) =>
                                  _openTaskDialog(taskId: id, existing: data),
                              onDelete: (id) => _confirmDelete(
                                  title: 'Aufgabe löschen?',
                                  message:
                                      'Möchtest du diese Aufgabe wirklich löschen?',
                                  onConfirm: () async {
                                    await _adminService.deleteTask(
                                        subjectId: _selectedSubjectId!,
                                        categoryId: _selectedCategoryId!,
                                        topicId: _selectedTopicId!,
                                        unitId: _selectedUnitId!,
                                        conceptId: _selectedConceptId!,
                                        learningBiteId:
                                            _selectedLearningBiteId!,
                                        taskId: id);
                                  }),
                            ),
                          ]),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Datei-Upload & KI-Generierung'),
                    const SizedBox(height: 12),
                    AiAuthoringCard(
                      userId: user.uid,
                      adminService: _adminService,
                      aiService: _aiService,
                      selectedSubjectId: _selectedSubjectId,
                      selectedCategoryId: _selectedCategoryId,
                      selectedTopicId: _selectedTopicId,
                      selectedUnitId: _selectedUnitId,
                      selectedConceptId: _selectedConceptId,
                      selectedLearningBiteId: _selectedLearningBiteId,
                      selectedLearningBiteData: _selectedLearningBiteData,
                      onUpdate: () {
                        if (_selectedSubjectId != null &&
                            _selectedCategoryId != null &&
                            _selectedTopicId != null &&
                            _selectedUnitId != null &&
                            _selectedConceptId != null &&
                            _selectedLearningBiteId != null) {
                          _adminService
                              .streamLearningBite(
                                  _selectedSubjectId!,
                                  _selectedCategoryId!,
                                  _selectedTopicId!,
                                  _selectedUnitId!,
                                  _selectedConceptId!,
                                  _selectedLearningBiteId!)
                              .first
                              .then((snap) {
                            if (mounted && snap.data() != null) {
                              setState(() {
                                _selectedLearningBiteData = snap.data();
                              });
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Adminverwaltung'),
                    const SizedBox(height: 12),
                    AdminManagementCard(
                      adminFunctions: _functionsService,
                      onEnsureAuthenticated: () async =>
                          FirebaseAuth.instance.currentUser != null,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _openSubjectDialog({
    required String userId,
    String? subjectId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openCategoryDialog({
    required String userId,
    required String subjectId,
    String? categoryId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => CategoryDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        categoryId: categoryId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openTopicDialog({
    required String userId,
    required String subjectId,
    required String categoryId,
    String? topicId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => TopicDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openUnitDialog({
    required String userId,
    required String subjectId,
    required String categoryId,
    required String topicId,
    String? unitId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => UnitDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openConceptDialog({
    required String userId,
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    String? conceptId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ConceptDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openLearningBiteDialog({
    required String userId,
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    String? learningBiteId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => LearningBiteDialog(
        adminService: _adminService,
        userId: userId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        learningBiteId: learningBiteId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openContentDialog({
    int? index,
    String? initialContent,
    List<String>? allContent,
  }) async {
    if (_selectedSubjectId == null ||
        _selectedCategoryId == null ||
        _selectedTopicId == null ||
        _selectedUnitId == null ||
        _selectedConceptId == null ||
        _selectedLearningBiteId == null) {
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        adminService: _adminService,
        subjectId: _selectedSubjectId!,
        categoryId: _selectedCategoryId!,
        topicId: _selectedTopicId!,
        unitId: _selectedUnitId!,
        conceptId: _selectedConceptId!,
        learningBiteId: _selectedLearningBiteId!,
        index: index,
        initialContent: initialContent,
        allContent: allContent,
      ),
    );
  }

  Future<void> _openTaskDialog({
    String? taskId,
    Map<String, dynamic>? existing,
  }) async {
    if (_selectedSubjectId == null ||
        _selectedCategoryId == null ||
        _selectedTopicId == null ||
        _selectedUnitId == null ||
        _selectedConceptId == null ||
        _selectedLearningBiteId == null) {
      return;
    }
    await showDialog(
      context: context,
      builder: (context) => TaskDialog(
        adminService: _adminService,
        subjectId: _selectedSubjectId!,
        categoryId: _selectedCategoryId!,
        topicId: _selectedTopicId!,
        unitId: _selectedUnitId!,
        conceptId: _selectedConceptId!,
        learningBiteId: _selectedLearningBiteId!,
        taskId: taskId,
        existingData: existing,
      ),
    );
  }

  Future<void> _openPreviewDialog({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
    required Map<String, dynamic> learningBiteData,
  }) async {
    final tasksSnapshot = await _adminService
        .streamTasks(
            subjectId, categoryId, topicId, unitId, conceptId, learningBiteId)
        .first;
    final tasks = tasksSnapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList();

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => PreviewDialog(
        adminService: _adminService,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        learningBiteId: learningBiteId,
        learningBiteData: learningBiteData,
        tasks: tasks,
      ),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }
}
