import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _roleController = TextEditingController(text: "cliente");
  bool _loading = false;

  final _authService = AuthService();

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final role = _roleController.text.trim();

    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      _showSnack("Por favor completa todos los campos");
      return;
    }

    setState(() => _loading = true);

    final response = await _authService.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );

    setState(() => _loading = false);

    if (response != null && response.containsKey('email')) {
      _showSnack("Cuenta creada correctamente");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnack("Error al crear la cuenta");
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

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/LOGO.png', width: 120),
                const SizedBox(height: 30),
                const Text(
                  "Crear Cuenta",
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.blancoTransparente,
                    hintText: "Nombre completo",
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AppColors.negro,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.blancoTransparente,
                    hintText: "Correo electrónico",
                    prefixIcon: const Icon(Icons.email, color: AppColors.negro),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.blancoTransparente,
                    hintText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock, color: AppColors.negro),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _loading ? null : _register,
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
                            "Crear Cuenta",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
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
    );
  }
}
