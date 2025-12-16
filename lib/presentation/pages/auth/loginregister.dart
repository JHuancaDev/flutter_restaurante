import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/presentation/pages/auth/login.dart';
import 'package:flutter_restaurante/data/services/auth_service.dart';
import 'package:flutter_restaurante/data/services/google_signin_service.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  final AuthService _authService = AuthService();
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  bool _isLoading = false;

  Future<void> _onGooglePressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🟡 Iniciando proceso de login con Google...');

      // 1. Iniciar sesión con Google y Firebase
      final googleData = await _googleSignInService.signIn();

      if (googleData != null && googleData['idToken'] != null) {
        final idToken = googleData['idToken']!;
        final email = googleData['email'] ?? 'No email';
        final uid = googleData['uid'] ?? 'No UID';

        final result = await _authService.loginWithGoogle(idToken);

        if (mounted) {
          // 3. Navegar a la página principal
          Navigator.pushReplacementNamed(context, '/home');

          // 4. Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['is_new_user']
                    ? '¡Bienvenido! Cuenta creada exitosamente'
                    : '¡Bienvenido de vuelta!',
                style: const TextStyle(color: AppColors.blanco),
              ),
              backgroundColor: AppColors.bottonPrimary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo completar el inicio de sesión con Google',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onLoginPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _onRegisterPressed() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.fondoPrimary, AppColors.fondoSecondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  Image.asset(
                    'assets/images/LOGO.png',
                    width: 130,
                    height: 130,
                  ),
                  const SizedBox(height: 30),

                  // TÍTULO
                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // SUBTÍTULO
                  const Text(
                    "Inicia sesión para continuar",
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // BOTÓN GOOGLE
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onGooglePressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blanco,
                        foregroundColor: AppColors.negro,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.borderButton,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.negro,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Continuar con Google",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // DIVIDER
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppColors.blanco.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "O",
                          style: TextStyle(
                            color: AppColors.blanco.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppColors.blanco.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // BOTÓN LOGIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bottonPrimary,
                        foregroundColor: AppColors.blanco,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Iniciar Sesión con Email",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // BOTÓN REGISTRO
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _onRegisterPressed,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.blanco,
                        side: const BorderSide(
                          color: AppColors.blanco,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Crear Cuenta Nueva",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TÉRMINOS Y CONDICIONES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Al continuar, aceptas nuestros Términos de Servicio y Política de Privacidad",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blanco.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
