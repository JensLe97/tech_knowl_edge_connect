import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/services/user/learning_material_service.dart';
import 'package:tech_knowl_edge_connect/models/user/learning_material.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';

class CompactLearningMaterialTile extends StatelessWidget {
  final LearningMaterial material;
  final void Function()? onTap;

  const CompactLearningMaterialTile({
    super.key,
    required this.material,
    this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yy').format(date);
  }

  void _toggleLike(BuildContext context) async {
    final firebaseAuth = FirebaseAuth.instance;
    final learningMaterialsService = LearningMaterialService();
    final userState = UserState.of(context);
    if (userState == null) return;

    final likedLearningMaterials = userState.likedLearningMaterials;
    if (likedLearningMaterials.contains(material.id)) {
      await learningMaterialsService.unlikeLearningMaterial(
          firebaseAuth.currentUser!.uid, material.id);
    } else {
      await learningMaterialsService.likeLearningMaterial(
          firebaseAuth.currentUser!.uid, material.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userState = UserState.of(context);
    final likedLearningMaterials = userState?.likedLearningMaterials ?? [];
    final isLiked = likedLearningMaterials.contains(material.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: cs.outlineVariant.withAlpha(40)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    LearningMaterialType.getIconForType(material.type),
                    color: cs.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              material.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(material.createdAt.toDate()),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurfaceVariant.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              material.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cs.onSurfaceVariant.withAlpha(200),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _toggleLike(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 6.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 16,
                                      color: isLiked
                                          ? Colors.redAccent
                                          : cs.onSurfaceVariant.withAlpha(150),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      material.numberOfLikes.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            cs.onSurfaceVariant.withAlpha(150),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
