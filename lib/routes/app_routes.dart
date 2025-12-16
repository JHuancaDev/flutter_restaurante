import 'package:flutter/material.dart';
import 'package:flutter_restaurante/data/models/product.dart';
import 'package:flutter_restaurante/presentation/pages/auth/forgot_password_page.dart';
import 'package:flutter_restaurante/presentation/pages/auth/login.dart';
import 'package:flutter_restaurante/presentation/pages/auth/loginregister.dart';
import 'package:flutter_restaurante/presentation/pages/auth/register_page.dart';
import 'package:flutter_restaurante/presentation/pages/cart/cart_page.dart';
import 'package:flutter_restaurante/presentation/pages/cart/my_orders_page.dart';
import 'package:flutter_restaurante/presentation/pages/favorites/favorites_page.dart';
import 'package:flutter_restaurante/presentation/pages/notifications/notifications_page.dart';
import 'package:flutter_restaurante/presentation/pages/products/product_detail_page.dart';
import 'package:flutter_restaurante/presentation/pages/products/products_page.dart';
import 'package:flutter_restaurante/presentation/pages/profile/profile_page.dart';
import 'package:flutter_restaurante/presentation/pages/splash/splash_page.dart';
import 'package:flutter_restaurante/presentation/pages/widgets/bottom_nav.dart';

final routes = {
  '/': (context) => const SplashPage(),
  '/login_or_register': (context) => const LoginOrRegister(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/forgot-password': (context) => const ForgotPasswordPage(),
  '/home': (context) => const BottomNavScreen(), // Aquí usamos BottomNavScreen
  '/products': (context) => const ProductsPage(),
  '/product-detail': (context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    return ProductDetailPage(product: product);
  },
  '/cart': (context) => const CartPage(),
  '/profile': (context) => const ProfilePage(),
  '/favorite': (context) => const FavoritesPage(),
  '/my-order': (context) => const MyOrdersPage(),
  '/notifications': (context) => const NotificationsPage(),
};
