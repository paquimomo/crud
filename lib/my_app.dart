import 'package:flutter/material.dart';
import 'login_menu.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ccook demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 223, 196, 48)),
        useMaterial3: true,
      ),
      home: const LoginMenu(title: 'Log-in Menu'),
    );
  }
}