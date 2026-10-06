import 'package:flutter/material.dart';
import 'package:basics/features/auth/presentation/screens/login_screen.dart';

class JetpunkApp extends StatelessWidget {
  const JetpunkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}
