import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/compact_learning_material_tile.dart';
import 'package:tech_knowl_edge_connect/components/detailed_learning_material_tile.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_reel_item.dart';
import 'package:tech_knowl_edge_connect/data/index.dart' show blockedUsers;
import 'package:tech_knowl_edge_connect/models/learning_material.dart';
import 'package:tech_knowl_edge_connect/pages/library/learning_material_preview_page.dart';
import 'package:tech_knowl_edge_connect/services/learning_material_service.dart';

class LearningFeedPage extends StatefulWidget {
  const LearningFeedPage({super.key});

  @override
  State<LearningFeedPage> createState() => _LearningFeedPageState();
}

class _LearningFeedPageState extends State<LearningFeedPage> {
  Future<void> _onRefresh() async {
    setState(() {});
  }

  int _currentView = 0; // 0: Reel, 1: Detailed List, 2: Compact List

  final LearningMaterialService _materialService = LearningMaterialService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Lern-Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Theme.of(context).colorScheme.surface,
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                enableDrag: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.view_carousel),
                          title: const Text('Reel-Ansicht'),
                          onTap: () {
                            setState(() {
                              _currentView = 0;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.list),
                          title: const Text('Detaillierte Listenansicht'),
                          onTap: () {
                            setState(() {
                              _currentView = 1;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.view_list),
                          title: const Text('Kompakte Listenansicht'),
                          onTap: () {
                            setState(() {
                              _currentView = 2;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildLearningFeed(),
    );
  }

  Widget _buildLearningFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: _materialService.getAllPublicLearningMaterials(
          excludeUserId: _firebaseAuth.currentUser?.uid ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Keine Lernmaterialien verfügbar.'));
        } else {
          final materials = snapshot.data!.docs
              .where((doc) => !blockedUsers.contains(doc['userId']))
              .map((doc) {
            return LearningMaterial.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          switch (_currentView) {
            case 0:
              return _buildReelView(materials);
            case 1:
              return _buildDetailedListView(materials);
            case 2:
              return _buildCompactListView(materials);
            default:
              return const Center(child: Text('Ungültiger Ansichtstyp'));
          }
        }
      },
    );
  }

  Widget _buildReelView(List<LearningMaterial> materials) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: PageView(
        scrollDirection: Axis.vertical,
        children: materials.map((material) {
          return LearningMaterialReelItem(material: material);
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedListView(List<LearningMaterial> materials) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: materials.length,
        itemBuilder: (context, index) {
          final material = materials[index];
          return DetailedLearningMaterialTile(
            material: material,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LearningMaterialPreviewPage(
                    url: material.url,
                    type: material.type,
                    name: material.name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCompactListView(List<LearningMaterial> materials) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        itemCount: materials.length,
        itemBuilder: (context, index) {
          return CompactLearningMaterialTile(
            material: materials[index],
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LearningMaterialPreviewPage(
                    url: materials[index].url,
                    type: materials[index].type,
                    name: materials[index].name,
                  ),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
