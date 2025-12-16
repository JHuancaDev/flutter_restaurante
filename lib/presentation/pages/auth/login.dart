import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/services/auth_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  final _authService = AuthService();

  final _tokenStorage = TokenStorage();

  Future<void> _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Por favor completa todos los campos");
      setState(() => _loading = false);
      return;
    }

    final response = await _authService.login(email, password);
    setState(() => _loading = false);

    if (response != null && response.containsKey('access_token')) {
      final token = response['access_token'];

      /// ✅ Guardamos el token
      await _tokenStorage.saveToken(token);

      _showSnack("Inicio de sesión exitoso ✅");

      // ✅ Aquí ya puedes navegar a tu HomePage
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnack("Credenciales inválidas ❌");
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bottonPrimary,
      ),
    );
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/LOGO.png', width: 120),
                  const SizedBox(height: 30),
                  const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.blancoTransparente,
                      hintText: "Correo electrónico",
                      prefixIcon: const Icon(
                        Icons.email,
                        color: AppColors.negro,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.blancoTransparente,
                      hintText: "Contraseña",
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: AppColors.negro,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Login
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _loading ? null : _login,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          _loading
                              ? AppColors.bottonPrimary.withOpacity(0.5)
                              : AppColors.bottonPrimary,
                        ),
                        foregroundColor: const WidgetStatePropertyAll(
                          AppColors.blanco,
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Iniciar Sesión",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                  onPressed: _goToRegister,
                  child: const Text(
                    "No tienes cuenta? Crea una",
                    style: TextStyle(
                      color: AppColors.blanco,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
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

  void _goToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }
}

