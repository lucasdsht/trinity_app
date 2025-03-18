import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/token_service.dart';
import 'productdetail_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  Set<int> _cartProducts = {}; // Stocke les produits déjà ajoutés
  TextEditingController _searchController = TextEditingController();
  int? _invoiceId;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _createOrGetInvoice();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _fetchProducts() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      final response = await Dio().get(
        '$apiBaseUrl/products/',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = response.data;
          _filteredProducts = _products;
        });
      }
    } catch (e) {
      print("Erreur de chargement des produits: $e");
    }
  }

  Future<bool> isProductInCart(int productId, int invoiceId) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return false;

      final response = await Dio().get(
        '$apiBaseUrl/invoices/items/$invoiceId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> items = response.data;

        // Vérifier si le produit est dans le panier avec une quantité >= 1
        return items.any((item) => item["product_id"] == productId && item["quantity"] >= 1);
      }
    } catch (e) {
      print("Erreur lors de la vérification du produit dans le panier: $e");
    }

    return false; // Retourne false en cas d'erreur
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((product) => product["name"].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _createOrGetInvoice() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      final dio = Dio();
      final getResponse = await dio.get(
        '$apiBaseUrl/invoices/?user_id=${await TokenService.getUserIdFromToken()}',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (getResponse.statusCode == 200 && getResponse.data.isNotEmpty) {
        _invoiceId = getResponse.data[0]["id"];
      } else {
        final postResponse = await dio.post(
          '$apiBaseUrl/invoices/',
          data: {
            "user_id": await TokenService.getUserIdFromToken(),
            "total_amount": 0,
            "payment_status": "PENDING"
          },
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
        _invoiceId = postResponse.data["id"];
      }
    } catch (e) {
      print("Erreur lors de la récupération de la facture: $e");
    }
  }

  Future<void> _addToCart(int productId, double price) async {
    if (_invoiceId == null) return;
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      await Dio().post(
        '$apiBaseUrl/invoices/items/',
        data: {
          "invoice_id": _invoiceId,
          "product_id": productId,
          "quantity": 1,
          "price_per_unit": price,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      setState(() {
        _cartProducts.add(productId);
      });

    } catch (e) {
      print("Erreur d'ajout au panier: $e");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produit ajouté au panier !")),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Rechercher un produit...",
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          final int productId = product["id"];
          final double price = product["price"];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: product["picture_url"] != null
                  ? Image.network(
                product["picture_url"],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
              )
                  : const Icon(Icons.image),
              title: Text(product["name"]),
              subtitle: Text("${price.toStringAsFixed(2)}€"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              trailing: FutureBuilder<bool>(
                  future: isProductInCart(productId, _invoiceId ?? 0),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Ou un autre widget de chargement
                    }

                    bool isInCart = snapshot.data ?? false;
                    if (isInCart) {
                      return IconButton(
                        icon: const Icon(Icons.check_box, color: Colors.green),
                        onPressed: () {
                          // Gérer l'action si le produit est déjà dans le panier (ex: retirer)
                        },
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () {
                          _addToCart(productId, price);
                        },
                        child: const Icon(Icons.shopping_cart),
                      );
                    }
                  }
              ),
            ),


          );
        },
      ),
    );
  }
}