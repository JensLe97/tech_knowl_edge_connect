import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
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
  final List<StreamSubscription<DocumentSnapshot>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadHierarchy();
  }

  Future<void> _loadHierarchy() async {
    try {
      // Clear any existing subscriptions if reloading
      for (final s in _subscriptions) {
        await s.cancel();
      }
      _subscriptions.clear();

      final pathSegments = widget.reference.path.split('/');
      // Path structure expected for deep learning-bite refs. If it's shorter
      // we bail out gracefully.
      if (pathSegments.length < 10) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final refs = <DocumentReference>[];

      // Subject
      refs.add(firestore.collection('content_subjects').doc(pathSegments[1]));

      // Category
      if (pathSegments.length >= 4) {
        refs.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3]));
      }

      // Topic
      if (pathSegments.length >= 6) {
        refs.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5]));
      }

      // Unit
      if (pathSegments.length >= 8) {
        refs.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5])
            .collection('units')
            .doc(pathSegments[7]));
      }

      // Concept
      if (pathSegments.length >= 10) {
        refs.add(firestore
            .collection('content_subjects')
            .doc(pathSegments[1])
            .collection('categories')
            .doc(pathSegments[3])
            .collection('topics')
            .doc(pathSegments[5])
            .collection('units')
            .doc(pathSegments[7])
            .collection('concepts')
            .doc(pathSegments[9]));
      }

      final snapshots = await Future.wait(refs.map((r) => r.get()));
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

      for (var i = 0; i < refs.length; i++) {
        final ref = refs[i];
        final sub = ref.snapshots().listen((doc) {
          final newItem = doc.exists
              ? {
                  'name': (doc.data() as Map<String, dynamic>?)?['name']
                          ?.toString() ??
                      'Unbenannt',
                  'status': (doc.data() as Map<String, dynamic>?)?['status']
                          ?.toString() ??
                      UserConstants.statusPrivate,
                }
              : {
                  'name': '???',
                  'status': UserConstants.statusPrivate,
                };

          if (!mounted) return;
          setState(() {
            if (_items.length > i) {
              _items[i] = newItem;
            } else {
              _items.add(newItem);
            }
          });
        }, onError: (e) {
          if (!mounted) return;
          setState(() {
            _error = e.toString();
          });
        });
        _subscriptions.add(sub);
      }

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
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 16,
        width: 100,
        child: LinearProgressIndicator(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    if (_error != null) {
      return Text('Fehler beim Laden der Hierarchie',
          style: (widget.style ?? const TextStyle()).copyWith(
              color: Theme.of(context).colorScheme.error, fontSize: 10));
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
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final sc = UserConstants.getStatusColors(
            item['status'] ?? UserConstants.statusPrivate, cs, isDark);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: sc.background,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: sc.border),
              ),
              child: Text(
                item['name']!,
                style: (widget.style ?? Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                        fontSize: 12,
                        color: sc.text,
                        fontWeight: FontWeight.w600),
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
