import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/detail/product_grid_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const WelcomeScreen(),
  '/login': (_) => const LoginScreen(),
  '/signup': (_) => const SignUpScreen(),
  '/home': (_) => const HomeScreen(),
  '/profile': (context) => const ProfileScreen(),

  '/products':
      (context) =>
          const ProductGridScreen(profileImage: 'assets/images/aura.png'),
};
