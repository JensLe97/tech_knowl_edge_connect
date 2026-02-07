import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserState extends InheritedWidget {
  final List<String> blockedUsers;
  final List<String> likedLearningMaterials;
  final Map<String, dynamic>? userData;

  const UserState({
    super.key,
    required this.blockedUsers,
    required this.likedLearningMaterials,
    this.userData,
    required super.child,
  });

  static UserState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserState>();
  }

  @override
  bool updateShouldNotify(UserState oldWidget) {
    return oldWidget.blockedUsers != blockedUsers ||
        oldWidget.likedLearningMaterials != likedLearningMaterials ||
        oldWidget.userData != userData;
  }
}

class UserProvider extends StatefulWidget {
  final Widget child;

  const UserProvider({super.key, required this.child});

  @override
  State<UserProvider> createState() => _UserProviderState();
}

class _UserProviderState extends State<UserProvider> {
  User? currentUser;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
          _userStream = FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser!.uid)
              .snapshots();
        });
      } else {
        setState(() {
          currentUser = null;
          _userStream = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userStream == null) {
      return UserState(
        blockedUsers: const [],
        likedLearningMaterials: const [],
        userData: null,
        child: widget.child,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _userStream,
      builder: (context, snapshot) {
        List<String> blockedUsers = [];
        List<String> likedLearningMaterials = [];
        Map<String, dynamic>? userData;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          userData = snapshot.data!.data();
          if (userData != null) {
            blockedUsers = userData['blockedUsers'] != null
                ? List<String>.from(userData['blockedUsers'])
                : [];
            likedLearningMaterials = userData['likedLearningMaterials'] != null
                ? List<String>.from(userData['likedLearningMaterials'])
                : [];
          }
        }

        return UserState(
          blockedUsers: blockedUsers,
          likedLearningMaterials: likedLearningMaterials,
          userData: userData,
          child: widget.child,
        );
      },
    );
  }
}
