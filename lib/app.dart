import 'package:flutter/material.dart';
import 'routes.dart';

class CrickArenaApp extends StatelessWidget {
  const CrickArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CrickArena',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
