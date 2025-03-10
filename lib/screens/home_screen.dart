import 'package:flutter/material.dart';
import './product_screen.dart';

class HomeScreen extends StatelessWidget {
  void logout(BuildContext context) {
    // Ajoute ici la logique de déconnexion si nécessaire
    Navigator.pushReplacementNamed(context, "/login"); // Exemple de redirection après déconnexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen(cart: {})), // Navigation vers la page des produits
                );
              },
              child: const Text("Go to Products"),
            ),
            const SizedBox(height: 20), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () => logout(context),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
