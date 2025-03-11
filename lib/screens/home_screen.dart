import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section "Produits Conseillés"
          const Text(
            "🔹 Produits Conseillés",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Voir pour afficher les produits conseillés
          const SizedBox(height: 20),

          // Section "Produits en Promotion"
          const Text(
            "🔥 Produits en Promotion",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          // Voir pour afficher les produits en promotion
        ],
      ),
    );
  }
}
