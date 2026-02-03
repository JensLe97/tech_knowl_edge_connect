import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    app: FirebaseAuth.instance.app,
    region: 'us-central1',
  );

  Future<void> setAdmin({required String uid}) async {
    final callable = _functions.httpsCallable('setAdmin');
    await callable.call({'uid': uid});
  }

  Future<void> revokeAdmin({required String uid}) async {
    final callable = _functions.httpsCallable('revokeAdmin');
    await callable.call({'uid': uid});
  }
}
