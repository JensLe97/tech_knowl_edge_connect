import 'package:firebase_auth/firebase_auth.dart';

class AdminClaimsService {
  Stream<bool> adminChanges({bool forceRefresh = false}) {
    return FirebaseAuth.instance.idTokenChanges().asyncMap((user) async {
      if (user == null) return false;
      final token = await user.getIdTokenResult(forceRefresh);
      return token.claims?['admin'] == true;
    });
  }

  Future<bool> isAdmin({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(forceRefresh);
    return token.claims?['admin'] == true;
  }
}
