import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/token_service.dart';
import 'navigation_bar.dart';
import 'productdetail_screen.dart';

class ProductScreen extends StatefulWidget {
  final String? barcode;

  const ProductScreen({Key? key, this.barcode}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  Set<int> _cartProducts = {};
  final TextEditingController _searchController = TextEditingController();
  int? _invoiceId;
  bool _isLoading = true;
  bool _showProductList = true;

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
          _isLoading = false;
        });

        // 🔍 Si un code-barres est fourni, chercher et rediriger
        if (widget.barcode != null) {
          final product = _products.firstWhere(
            (p) => p["barcode"] == widget.barcode,
            orElse: () => null,
          );

          if (product != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationBarWidget(
                    body: ProductDetailScreen(product: product),
                  ),
                ),
              );
            });
            setState(() => _showProductList = false); // Empêche l'affichage de la liste
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Produit avec code ${widget.barcode} introuvable.")),
              );
            });
          }
        }
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
        return items.any(
          (item) => item["product_id"] == productId && item["quantity"] >= 1,
        );
      }
    } catch (e) {
      print("Erreur vérification panier : $e");
    }

    return false;
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
      print("Erreur création ou récupération de facture : $e");
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produit ajouté au panier !")),
      );
    } catch (e) {
      print("Erreur ajout panier : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_showProductList) {
      return const Scaffold(body: SizedBox.shrink()); // N'affiche rien si redirection
    }

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
                    builder: (context) => NavigationBarWidget(
                      body: ProductDetailScreen(product: product),
                    ),
                  ),
                );
              },
              trailing: FutureBuilder<bool>(
                future: isProductInCart(productId, _invoiceId ?? 0),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  bool isInCart = snapshot.data ?? false;
                  if (isInCart) {
                    return const Icon(Icons.check_box, color: Colors.green);
                  } else {
                    return ElevatedButton(
                      onPressed: () => _addToCart(productId, price),
                      child: const Icon(Icons.shopping_cart),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

