import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/token_service.dart';
import 'cart_screen.dart';
import 'productdetail_screen.dart';
import 'home_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = [];
  Map<int, int> _tempCart = {}; // Product ID -> Quantity
  Map<int, int> _cartItems = {}; // Product ID -> Item ID (for deletion)
  int? _invoiceId;
  

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _createOrGetInvoice();
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
        });
      }
    } catch (e) {
      print("Erreur de chargement des produits: $e");
    }
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

      if (_invoiceId != null) {
        _fetchCartItems();
      }
    } catch (e) {
      print("Erreur lors de la récupération de la facture: $e");
    }
  }

  Future<void> _fetchCartItems() async {
    if (_invoiceId == null) return;
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      final response = await Dio().get(
        '$apiBaseUrl/invoices/items/$_invoiceId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _tempCart.clear();
          _cartItems.clear();
          for (var item in response.data) {
            int productId = item["product_id"];
            int quantity = item["quantity"];
            int itemId = item["id"];
            _tempCart[productId] = quantity;
            _cartItems[productId] = itemId;
          }
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des items du panier: $e");
    }
  }

  void _addToTempCart(int productId) {
    setState(() {
      _tempCart[productId] = (_tempCart[productId] ?? 0) + 1;
    });
  }

  void _removeFromTempCart(int productId) {
    if (_tempCart.containsKey(productId)) {
      setState(() {
        if (_tempCart[productId]! > 1) {
          _tempCart[productId] = _tempCart[productId]! - 1;
        } else {
          _tempCart.remove(productId);
        }
      });
    }
  }

  //sycrnonise avec l'api
  Future<void> _syncCartWithApi() async {
    if (_invoiceId == null) return;
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      final dio = Dio();

      // Supprimer tous les produits du panier avant de re-synchroniser
      for (var entry in _cartItems.entries) {
        await dio.delete(
          '$apiBaseUrl/invoices/items/${entry.value}',
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
      }

      // Ajouter les nouveaux produits
      for (var entry in _tempCart.entries) {
        await dio.post(
          '$apiBaseUrl/invoices/items/',
          data: {
            "invoice_id": _invoiceId,
            "product_id": entry.key,
            "quantity": entry.value,
            "price_per_unit":
                _products.firstWhere((p) => p["id"] == entry.key)["price"],
          },
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
      }

      // Recharger les produits du panier après synchronisation
      _fetchCartItems();
    } catch (e) {
      print("Erreur de synchronisation du panier: $e");
    }
  }

  @override
  void dispose() {
    _syncCartWithApi();
    super.dispose();
  }

  Color _getRestantColor(int stock, int quantityInCart) {
    if ((stock - quantityInCart) > 10) {
      return Colors.blue;
    } else if ((stock - quantityInCart) > 0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getRestantText(int stock, int quantityInCart) {
    if ((stock - quantityInCart) > 10) {
      return "Disponible";
    } else if ((stock - quantityInCart) > 1) {
      return "Plus que ${stock - quantityInCart} en stocks";
    } else if ((stock - quantityInCart) > 0) {
      return "Plus que 1 en stock";
    } else {
      return "Rupture de stock";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final int productId = product["id"];
          final stockQuantity = product["stock_quantity"];

          return Card(
            margin: EdgeInsets.all(8.0),
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
              onTap: () async {
                await _syncCartWithApi();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${product["price"]}€"),
                  Text(
                    _getRestantText(stockQuantity, _tempCart[productId] ?? 0),
                    style: TextStyle(
                        color: _getRestantColor(
                            stockQuantity, _tempCart[productId] ?? 0)),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_tempCart.containsKey(productId) &&
                      _tempCart[productId]! > 0)
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.red),
                      onPressed: (_tempCart[productId] ?? 0) > 0
                          ? () => _removeFromTempCart(productId)
                          : null,
                    ),
                  Text("${_tempCart[productId] ?? 0}"),
                  if (stockQuantity > (_tempCart[productId] ?? 0))
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: () => _addToTempCart(productId),
                    ),
                  if (stockQuantity <= (_tempCart[productId] ?? 0))
                    const SizedBox(width: 48),
                ],
              ),
            ),
            
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await _syncCartWithApi();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Panier modifié !")),
              );
            }
          },
          child: const Text("Commander"),
        ),
      ),
    );
  }
}
