import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  Color QuantiteColor(int stock) {
    switch (stock) {
      case 0:
        return Colors.red;
      case > 0 && < 10 :
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product["name"])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: product["picture_url"] != null
                  ? Image.network(
                product["picture_url"],
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
              )
                  : const Icon(Icons.image, size: 100),
            ),
             const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nom : ${product["name"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Marque : ${product["brand"]}", style: const TextStyle(fontSize: 18)),
                    Text("Catégorie : ${product["category"]}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Prix : \$${product["price"].toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Text("Quantité en stock : ${product["stock_quantity"]}", style: TextStyle(fontSize: 18, color: QuantiteColor(product["stock_quantity"]))),
                    const SizedBox(height: 8),
                    Text("Informations nutritionnelles : ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    product["nutritional_information"] != null && product["nutritional_information"].isNotEmpty
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (product["nutritional_information"] as Map<String, dynamic>).entries.map((entry) {
                        return Text("${entry.key} : ${entry.value}");
                      }).toList(),
                    )
                        : const Text("Aucune information nutritionnelle disponible."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}
