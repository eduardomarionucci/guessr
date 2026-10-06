import 'package:flutter/material.dart';

class StartupErrorApp extends StatelessWidget {
  final String details;
  const StartupErrorApp({super.key, required this.details});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SelectableText(
          'Não foi possível iniciar o Firebase.\nErro: $details\n\n'
          'Verifique a configuração, a conexão e o login anônimo no Firebase.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
