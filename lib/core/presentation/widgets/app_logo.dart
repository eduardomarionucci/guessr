import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  const AppLogo({super.key, this.width = 240});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Image.asset(
      'assets/images/logo.png',
      width: width,
      fit: BoxFit.contain,
      semanticLabel: 'Logo do aplicativo',
    ),
  );
}
