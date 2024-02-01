import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    FirebaseFirestore.instance
        .collection("Users")
        .doc(gUser.email)
        .get()
        .then((data) {
      if (!data.exists) {
        createUserDocument(gUser);
      }
    });

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> createUserDocument(GoogleSignInAccount? gUser) async {
    if (gUser != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(gUser.email)
          .set({
        'email': gUser.email,
        'username': gUser.displayName,
      });
    }
  }
}
