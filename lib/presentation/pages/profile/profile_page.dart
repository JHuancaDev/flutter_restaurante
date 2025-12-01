import 'package:flutter/material.dart';
import 'package:flutter_restaurante/config/theme.dart';
import 'package:flutter_restaurante/data/models/user_model.dart';
import 'package:flutter_restaurante/data/services/user_service.dart';
import 'package:flutter_restaurante/data/services/token_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  final TokenStorage _tokenStorage = TokenStorage();
  late Future<User> _userFuture;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<User> _loadUserData() async {
    try {
      final userData = await _userService.getCurrentUser();
      final user = User.fromJson(userData);
      _currentUser = user;
      return user;
    } catch (e) {
      // Re-lanzamos la excepción para que FutureBuilder la capture
      throw e;
    }
  }

  void _showEditDialog() {
    if (_currentUser == null) return;

    final nameController = TextEditingController(text: _currentUser?.fullName);
    final emailController = TextEditingController(text: _currentUser?.email);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña (opcional)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updateUserProfile(
              nameController.text,
              emailController.text,
              passwordController.text.isEmpty ? null : passwordController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bottonPrimary,
              foregroundColor: AppColors.blanco,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUserProfile(
    String fullName,
    String email,
    String? password,
  ) async {
    try {
      final updatedUser = await _userService.updateCurrentUser(
        email: email,
        fullName: fullName,
        password: password,
      );

      final user = User.fromJson(updatedUser);
      setState(() {
        _currentUser = user;
      });

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bottonSecundary,
              foregroundColor: AppColors.blanco,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tokenStorage.deleteToken();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _handleSessionExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            _logout();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.fondoPrimary,
        foregroundColor: AppColors.blanco,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.fondoPrimary),
              child: Text(
                "Hola, preciona lo que quieres saber...",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Pedidos"),
              onTap: () {
                Navigator.pop(context); // Cierra el menú
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notificaciones"),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.reviews),
              title: Text("Mis Ordenes"),
              onTap: () {
                Navigator.pushNamed(context, '/my-order');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error.toString();

            // Si el error es de sesión expirada, mostramos un mensaje específico
            if (error.contains('Sesión expirada')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleSessionExpired();
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar perfil',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _userFuture = _loadUserData();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bottonPrimary,
                        foregroundColor: AppColors.blanco,
                      ),
                      child: const Text('Reintentar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _logout,
                      child: const Text('Ir al login'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.fondoSecondary,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bottonPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Información del usuario
                _profileItem('Nombre Completo', user.fullName),
                _profileItem('Correo', user.email),
                _profileItem('Rol', user.role),
                _profileItem('Estado', user.isActive ? 'Activo' : 'Inactivo'),
                _profileItem(
                  'Miembro desde',
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),

                const SizedBox(height: 30),

                // Botón Editar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bottonPrimary,
                      foregroundColor: AppColors.blanco,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar perfil'),
                  ),
                ),

                const SizedBox(height: 10),

                // Botón Cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bottonSecundary,
                      foregroundColor: AppColors.blanco,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.blancoTransparente,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
