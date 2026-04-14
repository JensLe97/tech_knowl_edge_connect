import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    GoogleSignInAccount? gUser;
    try {
      gUser = await GoogleSignIn().signIn();
    } catch (e) {
      return null;
    }

    if (gUser == null) {
      return null;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid);
      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await createUserDocument(gUser, userCredential.user!.uid);
      }
    } catch (_) {}

    return userCredential;
  }

  Future<UserCredential?> signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    UserCredential userCredential;
    try {
      if (kIsWeb) {
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(appleProvider);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithProvider(appleProvider);
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
      GoogleSignInAccount? gUser, String uid) async {
    if (gUser != null) {
      await FirebaseFirestore.instance.collection("Users").doc(uid).set({
        'email': gUser.email,
        'username': gUser.displayName ?? "Anonymer User",
        'uid': uid,
      });
    }
  }

  Future<void> createAppleUserDocument(
      String email, String displayName, String uid) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).set({
      'email': email,
      'username': displayName,
      'uid': uid,
    });
  }
}
