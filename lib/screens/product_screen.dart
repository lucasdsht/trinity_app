import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/token_service.dart';
import 'cart.screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
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

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
  String _errorMessage = "";
  TextEditingController _searchController = TextEditingController();

  Map<int, int> _cart = {}; // Clé: ID produit, Valeur: quantité ajoutée

  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = "No token found, please login.";
          _isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        'http://10.0.2.2:8000/products',
        queryParameters: {"limit": 100},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _products = response.data;
          _filteredProducts = _products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load products";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        String name = product["name"].toString().toLowerCase();
        return name.contains(query);
      }).toList();
      _currentPage = 0; // Réinitialiser la page après filtrage
    });
  }

  void _nextPage() {
    if ((_currentPage + 1) * _itemsPerPage < _filteredProducts.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _addToCart(int productId, int stock) {
    setState(() {
      if (!_cart.containsKey(productId)) {
        _cart[productId] = 1;
      } else if (_cart[productId]! < stock) {
        _cart[productId] = _cart[productId]! + 1;
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        if (_cart[productId]! > 1) {
          _cart[productId] = _cart[productId]! - 1;
        } else {
          _cart.remove(productId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = _currentPage * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    List<dynamic> displayedProducts = _filteredProducts.sublist(
      startIndex,
      endIndex > _filteredProducts.length ? _filteredProducts.length : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produits"),
        actions: [
          Text(_cart.length.toString()),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(cart: _cart, products: _products),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un produit",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
          if (_filteredProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 0 ? _prevPage : null,
                    child: const Text("Précédent"),
                  ),
                  Text("Page ${_currentPage + 1} / ${(_filteredProducts.length / _itemsPerPage).ceil()}"),
                  ElevatedButton(
                    onPressed: (_currentPage + 1) * _itemsPerPage < _filteredProducts.length ? _nextPage : null,
                    child: const Text("Suivant"),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : displayedProducts.isEmpty
                ? const Center(child: Text("Aucun produit trouvé"))
                : ListView.builder(
              itemCount: displayedProducts.length,
              itemBuilder: (context, index) {
                final product = displayedProducts[index];
                final int stock = product["stock_quantity"] ?? 0;
                final int productId = product["id"];
                final int quantityInCart = _cart[productId] ?? 0;

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
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                    )
                        : const Icon(Icons.image),
                    title: Text(
                      product["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${product["brand"]} - \$${product["price"].toStringAsFixed(2)}"),
                        const SizedBox(height: 4),
                        Text(
                          _getRestantText(stock, quantityInCart),
                          style: TextStyle(
                            color: _getRestantColor(stock, quantityInCart),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (quantityInCart > 0)
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () => _removeFromCart(productId),
                          ),
                        Text("$quantityInCart"),
                        if (quantityInCart < stock)
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => _addToCart(productId, stock),
                          ),
                        if (quantityInCart == stock)
                          const SizedBox(width: 48),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
