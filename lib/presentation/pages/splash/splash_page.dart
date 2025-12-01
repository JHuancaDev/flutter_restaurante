import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/data/services/google_signin_service.dart';
import 'package:flutter_restaurante/presentation/pages/auth/loginregister.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/bottom_nav.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final TokenStorage _tokenStorage = TokenStorage();
  final GoogleSignInService _googleSignInService = GoogleSignInService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Espera un pequeño delay visual
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Primero verifica si hay token JWT guardado
      final token = await _tokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        // Si hay token JWT, ir directamente al home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
        return;
      }

      // Si no hay token JWT, verificar si hay sesión de Google activa
      final hasGoogleSession = await _googleSignInService.isSignedIn();
      
      if (hasGoogleSession && mounted) {
        // Intentar auto-login con Google
        final googleData = await _googleSignInService.getAuthTokensSilently();
        
        if (googleData != null && googleData['idToken'] != null) {
          // Aquí podrías implementar auto-login con el token de Google
          // Por ahora, vamos a la pantalla de login/register
          _navigateToLogin();
        } else {
          _navigateToLogin();
        }
      } else {
        _navigateToLogin();
      }
    } catch (error) {
      print('Error en splash: $error');
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginOrRegister()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tu logo
            Image.asset(
              'assets/images/LOGO.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.blanco),
            ),
          ],
        ),
      ),
    );
  }
}