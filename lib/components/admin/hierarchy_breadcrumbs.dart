import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class HierarchyBreadcrumbs extends StatefulWidget {
  final DocumentReference reference;
  final TextStyle? style;

  const HierarchyBreadcrumbs({
    super.key,
    required this.reference,
    this.style,
  });

  @override
  State<HierarchyBreadcrumbs> createState() => _HierarchyBreadcrumbsState();
}

class _HierarchyBreadcrumbsState extends State<HierarchyBreadcrumbs> {
  List<Map<String, String>> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHierarchy();
  }

  Future<void> _loadHierarchy() async {
    try {
      final pathSegments = widget.reference.path.split('/');
      // Path structure:
      // content_subjects/{sId}/categories/{cId}/topics/{tId}/units/{uId}/concepts/{coId}/learning_bites/{lbId}

      if (pathSegments.length < 10) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final List<Future<DocumentSnapshot>> futures = [];

      // Subject
      futures.add(
          firestore.collection('content_subjects').doc(pathSegments[1]).get());

      // Category
      if (pathSegments.length >= 4) {
        futures.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .get());
      }

      // Topic
      if (pathSegments.length >= 6) {
        futures.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5])
            .get());
      }

      // Unit
      if (pathSegments.length >= 8) {
        futures.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5])
            .collection('units')
            .doc(pathSegments[7])
            .get());
      }

      // Concept
      if (pathSegments.length >= 10) {
        futures.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5])
            .collection('units')
            .doc(pathSegments[7])
            .collection('concepts')
            .doc(pathSegments[9])
            .get());
      }

      final snapshots = await Future.wait(futures);
      final items = snapshots.map((doc) {
        if (!doc.exists) {
          return {
            'name': '???',
            'status': UserConstants.statusPrivate,
          };
        }
        final data = doc.data() as Map<String, dynamic>?;
        return {
          'name': data?['name']?.toString() ?? 'Unbenannt',
          'status': data?['status']?.toString() ?? UserConstants.statusPrivate,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 16,
        width: 100,
        child: LinearProgressIndicator(),
      );
    }

    if (_error != null) {
      return Text('Fehler beim Laden der Hierarchie',
          style: (widget.style ?? const TextStyle())
              .copyWith(color: Colors.red, fontSize: 10));
    }

    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 4,
      children: _items.asMap().entries.map((entry) {
        final isLast = entry.key == _items.length - 1;
        final item = entry.value;
        final statusColor =
            UserConstants.getStatusColor(item['status'] ?? 'private');

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item['name']!,
                style: (widget.style ?? Theme.of(context).textTheme.bodySmall)
                    ?.copyWith(fontSize: 10, color: statusColor),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
