import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'providers/cart_provider.dart';
import 'providers/signup_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCfawcBAXNx8IpXK1XaJjIZUaQe5zoMU98",
          authDomain: "crickarena1.firebaseapp.com",
          projectId: "crickarena1",
          storageBucket: "crickarena1.appspot.com",
          messagingSenderId: "399003028616",
          appId: "1:399003028616:android:98ac7d345fbc0d9d66633d",
        ),
      );
    }
  } catch (e) {
    debugPrint("Firebase already initialized or error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const CrickArenaApp(),
    ),
  );
}
