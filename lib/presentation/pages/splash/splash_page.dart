import 'package:flutter/material.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';
import 'package:flutter_restaurante/presentation/pages/auth/loginregister.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/bottom_nav.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final TokenStorage _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Espera un pequeño delay visual
    await Future.delayed(const Duration(seconds: 1));

    // Obtiene el token desde FlutterSecureStorage
    final token = await _tokenStorage.getToken();

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginOrRegister()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
