import 'package:flutter/material.dart';

void main() {
  return runApp(const MaterialApp(home: Calculadora()));
}

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});
  @override
  CalculadoraState createState() => CalculadoraState();
}

class CalculadoraState extends State<Calculadora> {
  final _form = GlobalKey<FormState>();
  final firstNumberController = TextEditingController();
  final secondNumberController = TextEditingController();

  String resultado = "";

  void calcular() {
    if (_form.currentState!.validate()) {
      double num1 = double.parse(firstNumberController.text);
      double num2 = double.parse(secondNumberController.text);

      bool firstIsEven = (num1 % 2 == 0);
      bool secondIsEven = (num2 % 2 == 0);

      if (firstIsEven && secondIsEven) {
      } else if (!firstIsEven && secondIsEven) {
      } else if (firstIsEven && !secondIsEven) {
      } else {
        if (num2 == 0) {
          setState(() {
            resultado = "Erro: Não é possível dividir por zero!";
          });
          return;
        }
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Soma")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: firstNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Digite o primeiro número",
              ),
            ),
            TextFormField(
              controller: secondNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Digite o segundo número",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: calcular, child: const Text("Enviar")),
            const SizedBox(height: 24),
            Text(resultado),
          ],
        ),
      ),
    );
  }
}
