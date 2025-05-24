import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // NEW
import 'app.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // REQUIRED for async main

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCjkPm6K4swSJ2xaBqBJ39RSlxsOXCrm5A",
      authDomain: "crickarena-c713c.firebaseapp.com",
      projectId: "crickarena-c713c",
      storageBucket: "crickarena-c713c.appspot.com",
      messagingSenderId: "873824206863",
      appId: "1:873824206863:android:5c445c427cfd13f6d0e37a",
      measurementId: "YOUR_MEASUREMENT_ID", // optional
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Add other providers like AuthProvider here if needed
      ],
      child: const CrickArenaApp(),
    ),
  );
}
