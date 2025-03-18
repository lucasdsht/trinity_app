import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/api_service.dart';
import '../api/token_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List<dynamic> orderItems = [];
  Map<int, dynamic> productDetails =
      {}; // Stocke les détails des produits par ID
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  /// 🔹 Récupère les détails des produits et les associe aux produits commandés
  Future<void> _fetchOrderDetails() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      // 1️⃣ **Récupérer les produits de la commande**
      final orderResponse = await Dio().get(
        '$apiBaseUrl/invoices/items/${widget.order["id"]}', // Remplace par ton API
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (orderResponse.statusCode != 200) {
        setState(() {
          errorMessage = "Impossible de récupérer les produits de la commande.";
          isLoading = false;
        });
        return;
      }

      List<dynamic> orderProducts = orderResponse.data;

      // 2️⃣ **Récupérer la liste complète des produits**
      final productsResponse = await Dio().get(
        '$apiBaseUrl/products/', // 🔥 Remplace par ton API
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (productsResponse.statusCode != 200) {
        setState(() {
          errorMessage = "Impossible de récupérer les détails des produits.";
          isLoading = false;
        });
        return;
      }

      List<dynamic> allProducts = productsResponse.data;

      // 3️⃣ **Créer un dictionnaire {product_id: détails produit}**
      Map<int, dynamic> productMap = {
        for (var product in allProducts) product["id"]: product
      };

      // 4️⃣ **Associer chaque produit commandé avec ses détails**
      setState(() {
        orderItems = orderProducts;
        productDetails = productMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  /// 🔹 Convertit le statut en couleur
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "PAID":
        return Colors.green;
      case "PENDING":
        return Colors.orange;
      case "FAILED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 **Titre de la page**
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              "📦 Détails de la commande",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          /// 🔹 **Carte des détails de la commande**
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Commande #${widget.order["id"]}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Montant total:",
                          style: TextStyle(fontSize: 18)),
                      Text(
                        "${widget.order["total_amount"]} €",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Statut de paiement:",
                          style: TextStyle(fontSize: 18)),
                      Text(
                        widget.order["payment_status"],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _getStatusColor(widget.order["payment_status"]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// 🔹 **Liste des produits commandés**
          const SizedBox(height: 20),
          const Text(
            "🛍 Produits commandés",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Text(errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    )
                  : orderItems.isEmpty
                      ? const Center(
                          child: Text("Aucun produit trouvé.",
                              style: TextStyle(fontSize: 16)))
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: orderItems.length,
                            itemBuilder: (context, index) {
                              final item = orderItems[index];
                              final product =
                                  productDetails[item["product_id"]];

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: product != null &&
                                          product["picture_url"] != null
                                      ? Image.network(product["picture_url"],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.shopping_bag,
                                          color: Colors.blue),
                                  title: Text(
                                      product != null
                                          ? product["name"]
                                          : "Produit inconnu",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Quantité: ${item["quantity"]}"),
                                      Text(
                                          "Prix unitaire: ${item["price_per_unit"]} €"),
                                      Text(
                                          "Total: ${(item["quantity"] * item["price_per_unit"]).toStringAsFixed(2)} €"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

          /// 🔹 Bouton Retour
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Retour"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
