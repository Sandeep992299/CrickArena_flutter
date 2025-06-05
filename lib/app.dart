import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'providers/theme_provider.dart';

class CrickArenaApp extends StatelessWidget {
  const CrickArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CrickArena',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color.fromARGB(255, 208, 221, 137),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(179, 0, 0, 0)),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color.fromARGB(255, 2, 2, 2),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          bodyMedium: TextStyle(color: Color.fromARGB(179, 84, 81, 81)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
          suffixIconColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepOrange,
          secondary: Colors.orangeAccent,
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
      ),

      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
