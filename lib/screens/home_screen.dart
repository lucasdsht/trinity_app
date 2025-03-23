import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/token_service.dart';
import '../api/api_service.dart';
import 'productdetail_screen.dart';
import 'navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> products = [];
  List<dynamic> recommendedProducts = [];
  List<dynamic> randomProducts = [];
  bool isLoading = true;
  String? errorMessage;
  bool hasOrders = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchUserOrders();
  }

  /// 🔹 Vérifie si l'utilisateur a déjà commandé et génère des recommandations
  Future<void> _fetchUserOrders() async {
    try {
      String? token = await TokenService.getToken();
      int? userId = await TokenService.getUserIdFromToken();
      if (token == null) return;

      final response = await Dio().get(
        "$apiBaseUrl/invoices/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        List<dynamic> orderedProducts = response.data;
        List list_order_user = orderedProducts
            .where((invoice) => invoice["user_id"] == userId)
            .map<int>((invoice) => invoice["id"] as int)
            .toList();
        List<Map<String, dynamic>> userOrdersWithItems = [];
        List list_product_id = [];

        for (int invoiceId in list_order_user) {
          final itemsResponse = await Dio().get(
            "$apiBaseUrl/invoices/items/$invoiceId",
            options: Options(headers: {"Authorization": "Bearer $token"}),
          );

          if (itemsResponse.statusCode == 200 && itemsResponse.data is List) {
            List<int> productIds = itemsResponse.data
                .map<int>((item) => item["product_id"] as int)
                .toList();

            list_product_id.addAll(productIds);
          }
        }
        for (int product_id in list_product_id) {
          for (int i = 0; i < products.length; i++) {
            if (products[i]["id"] == product_id) {
              userOrdersWithItems.add(products[i]);
            }
          }
        }
        setState(() {
          hasOrders = true;
          _generateProductRecommendations(userOrdersWithItems);
        });
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération des commandes : $e");
    }
  }

  /// 🔹 Récupère tous les produits depuis l'API
  Future<void> _fetchProducts() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        '$apiBaseUrl/products/',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          setState(() {
            products = response.data;
            isLoading = false;
            if (!hasOrders) {
              _selectRandomProducts();
            }
          });
        } else {
          setState(() {
            errorMessage = "Format de réponse inattendu.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Impossible de récupérer les produits.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  /// 🔹 Sélectionne des produits aléatoires si l'utilisateur n'a pas commandé
  void _selectRandomProducts() {
    if (products.isNotEmpty) {
      final random = Random();
      List<dynamic> shuffledProducts = List.from(products)..shuffle(random);
      //print("Produit aléatoire : $shuffledProducts");
      setState(() {
        randomProducts = shuffledProducts.take(10).toList();
      });
    }
  }

  /// 🔹 Génère des recommandations basées sur les commandes passées
  void _generateProductRecommendations(List<dynamic> orderedProducts) {
    Set<String> brands = orderedProducts
        .map((p) => p["brand"]?.toString() ?? "")
        .where((b) => b.isNotEmpty)
        .toSet();

    Set<String> categories = orderedProducts
        .map((p) => p["category"]?.toString() ?? "")
        .where((c) => c.isNotEmpty)
        .toSet();

    //print("📦 Marques trouvées : $brands");
    //print("📦 Catégories trouvées : $categories");
    List<Map<String, dynamic>> matchedProducts = products
        .where((product) {
          final brand = product["brand"]?.toString() ?? "";
          final category = product["category"]?.toString() ?? "";
          return brands.any((b) => brand.contains(b)) ||
              categories.contains(category);
        })
        .cast<Map<String, dynamic>>()
        .toList();

    setState(() {
      recommendedProducts = matchedProducts.take(6).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 **Produits Conseillés**
          if (recommendedProducts.isNotEmpty) ...[
            const Text(
              "🔹 Produits Conseillés",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProductGrid(recommendedProducts),
          ] else if (randomProducts.isNotEmpty) ...[
            const Text(
              "🔹 Produits à Découvrir",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProductGrid(randomProducts),
          ],
        ],
      ),
    );
  }

  /// 🔹 Affichage des produits sous forme de grille (3 produits par ligne)
  Widget _buildProductGrid(List<dynamic> productList) {
    if (productList.isEmpty) {
      return const Center(
        child: Text("Aucun produit disponible", style: TextStyle(fontSize: 16)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 🔥 3 produits par ligne
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8, // 🔥 Ajuste la hauteur pour éviter l'overflow
      ),
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final product = productList[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationBarWidget(
                  body: ProductDetailScreen(product: product),
                ),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Ajout de Expanded pour éviter l'overflow
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _getProductImage(
                        product["picture_url"], product["name"]),
                  ),
                ),
                // ✅ Empêcher le texte d'overflow avec `Flexible`
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    product["name"] ?? "Produit inconnu",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // ✅ Empêche le texte de déborder
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔹 Gestion des images des produits
  Widget _getProductImage(String? imageUrl, String? productName) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        "assets/images/default_product.png",
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
