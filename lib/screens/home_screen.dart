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
  bool isLoading = true;
  String? errorMessage;
  bool hasOrders = false; // 🔥 Indique si l'utilisateur a déjà commandé

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _checkUserOrders();
  }

  /// 🔹 Vérifie si l'utilisateur a déjà passé une commande
  Future<void> _checkUserOrders() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      final response = await Dio().get(
        "$apiBaseUrl/invoices/",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          hasOrders = response.data.isNotEmpty;
        });
      }
    } catch (e) {
      print("❌ Erreur lors de la vérification des commandes : $e");
    }
  }

  /// 🔹 Récupère **tous les produits** avec le token JWT
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 **Produits Conseillés** (Affiché uniquement si l'utilisateur a commandé)
          if (hasOrders) ...[
            const Text(
              "🔹 Produits Conseillés",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading ? _buildLoadingIndicator() : _buildProductGrid(),
            const SizedBox(height: 20),
          ],

          // 🔥 **Promotions** (Toujours affiché)
          const Text(
            "🔥 Promotions",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 10),
          isLoading ? _buildLoadingIndicator() : _buildProductGrid(),
        ],
      ),
    );
  }

  /// 🔹 Affichage **dynamique** des produits (nom + image uniquement)
  Widget _buildProductGrid() {
    if (products.isEmpty) {
      return const Center(
        child: Text("Aucun produit disponible", style: TextStyle(fontSize: 16)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 🔥 2 produits par ligne
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7, // 🔥 Ajuste la hauteur des cartes
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NavigationBarWidget(
                    body: ProductDetailScreen(product: product)),
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
                // 🔹 Image du produit
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child:
                      _getProductImage(product["picture_url"], product["name"]),
                ),
                // 🔹 Nom du produit
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    product["name"] ?? "Produit inconnu",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔹 **Fonction pour gérer les images de produits**
  Widget _getProductImage(String? imageUrl, String? productName) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        "assets/images/default_product.png",
        height: 180, // 🔥 Augmente la taille de l’image
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl,
      height: 180, // 🔥 Taille augmentée pour plus de visibilité
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/images/default_product.png",
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// 🔹 Indicateur de chargement
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
