import 'package:flutter/material.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = const [
      "Geografia",
      "História",
      "Ciência",
      "Esportes",
      "Entretenimento",
      "Arte",
      "Literatura",
      "Música",
      "Tecnologia",
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Categorias")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    children: categories
                        .map((category) => ItemWidget(text: category))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior:
          Clip.antiAlias, // Garante que o efeito de clique respeite as bordas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        child: Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}
