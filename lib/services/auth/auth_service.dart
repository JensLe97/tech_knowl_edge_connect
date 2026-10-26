import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()..addScope('email');
      final userCredential = await FirebaseAuth.instance.signInWithPopup(
        provider,
      );
      await _ensureUserDocument(userCredential);
      return userCredential;
    }

    late GoogleSignInAccount gUser;
    try {
      gUser = await GoogleSignIn.instance.authenticate();
    } catch (e) {
      return null;
    }

    final GoogleSignInAuthentication gAuth = gUser.authentication;
    final GoogleSignInClientAuthorization? authorization = await gUser
        .authorizationClient
        .authorizationForScopes(const <String>['email']);

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: gAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    await _ensureUserDocument(userCredential);
    return userCredential;
  }

  Future<void> _ensureUserDocument(UserCredential userCredential) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        final user = userCredential.user!;
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'email': user.email ?? '',
          'username': user.displayName ?? 'Anonymer User',
          'uid': user.uid,
        });
      }
    } catch (_) {}
  }

  Future<UserCredential?> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    UserCredential userCredential;
    try {
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          appleProvider,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          appleProvider,
        );
      }
    } catch (e) {
      return null;
    }

    try {
      final uid = userCredential.user!.uid;
      final docRef = FirebaseFirestore.instance.collection('Users').doc(uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        final email = userCredential.user?.email ?? '';
        final displayName = userCredential.user?.displayName ?? 'Anonymer User';
        await createAppleUserDocument(email, displayName, uid);
      }
    } catch (_) {}

    return userCredential;
  }

  Future<void> createUserDocument(
    GoogleSignInAccount? gUser,
    String uid,
  ) async {
    if (gUser != null) {
      await FirebaseFirestore.instance.collection("Users").doc(uid).set({
        'email': gUser.email,
        'username': gUser.displayName ?? "Anonymer User",
        'uid': uid,
      });
    }
  }

  Future<void> createAppleUserDocument(
    String email,
    String displayName,
    String uid,
  ) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      'email': email,
      'username': displayName,
      'uid': uid,
    });
  }
}
