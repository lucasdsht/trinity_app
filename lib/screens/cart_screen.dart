import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final Map<int, int> cart; // Produit ID -> Quantité
  final List<dynamic> products;

  CartScreen({required this.cart, required this.products});

  @override
  Widget build(BuildContext context) {
    // Filtrer les produits qui sont dans le panier
    List<dynamic> cartProducts = products.where((product) => cart.containsKey(product["id"])).toList();

    // Calcul du prix total
    double totalPrice = cartProducts.fold(0, (sum, product) {
      int quantity = cart[product["id"]] ?? 0;
      return sum + (product["price"] * quantity);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body: cartProducts.isEmpty
          ? const Center(child: Text("Votre panier est vide."))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProducts.length,
              itemBuilder: (context, index) {
                final product = cartProducts[index];
                final int quantity = cart[product["id"]] ?? 0;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: product["picture_url"] != null
                        ? Image.network(
                      product["picture_url"],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.image),
                    title: Text(product["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Quantité: $quantity\nPrix: \$${(product["price"] * quantity).toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeFromCart(context, product["id"]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Total: \$${totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Action à définir pour le paiement
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Commande cliqué !")));
                  },
                  child: const Text("Commander"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _removeFromCart(BuildContext context, int productId) {
    cart.remove(productId);
    Navigator.pop(context); // Fermer et rouvrir pour mettre à jour l'affichage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen(cart: cart, products: products)),
    );
  }
}
