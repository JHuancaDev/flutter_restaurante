import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, String>?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user == null) {
        return null;
      }

      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        return null;
      }

      return {
        'idToken': firebaseIdToken,
        'accessToken': googleAuth.accessToken ?? '',
        'email': userCredential.user?.email ?? '',
        'displayName': userCredential.user?.displayName ?? '',

        'uid': userCredential.user?.uid ?? '',
      };
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<Map<String, String>?> getAuthTokensSilently() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final String? firebaseIdToken = await currentUser.getIdToken();

        if (firebaseIdToken != null) {
          return {
            'idToken': firebaseIdToken,
            'email': currentUser.email ?? '',
            'displayName': currentUser.displayName ?? '',
          };
        }
      }
      return null;
    } catch (error) {
      return null;
    }
  }
}
