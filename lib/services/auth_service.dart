import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser;
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

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.uid)
        .get()
        .then((data) {
      if (!data.exists) {
        createUserDocument(gUser, userCredential.user!.uid);
      }
    });

    return userCredential;
  }

  signInWithApple() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final UserCredential userCredential;
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

    FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.uid)
        .get()
        .then((data) {
      if (!data.exists) {
        createAppleUserDocument(userCredential.user!.email!,
            userCredential.user!.displayName!, userCredential.user!.uid);
      }
    });

    return userCredential;
  }

  Future<void> createUserDocument(
      GoogleSignInAccount? gUser, String uid) async {
    if (gUser != null) {
      await FirebaseFirestore.instance.collection("Users").doc(uid).set({
        'email': gUser.email,
        'username': gUser.displayName,
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
