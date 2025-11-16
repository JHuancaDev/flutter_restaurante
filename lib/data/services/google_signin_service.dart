import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Iniciar sesión con Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      return googleUser;
    } catch (error) {
      print('Error en Google Sign-In: $error');
      return null;
    }
  }

  // Cerrar sesión con Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Obtener token de autenticación
  Future<Map<String, String>?> getAuthTokens() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;
        
        return {
          'idToken': googleAuth.idToken ?? '',
          'accessToken': googleAuth.accessToken ?? '',
        };
      }
      return null;
    } catch (error) {
      print('Error obteniendo tokens: $error');
      return null;
    }
  }

  // Verificar si ya hay una sesión activa
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Obtener usuario actual
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}