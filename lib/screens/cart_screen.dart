import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/token_service.dart';
import 'dart:convert';
import '../screens/paypal_checkout.dart';
import '../screens/paypal_success.dart';
import '../screens/navigation_bar.dart';
import '../screens/paypal_form.dart';

final dio = Dio();

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService apiService = ApiService();
  int? cartId;
  List<dynamic> cartItems = [];
  bool isLoading = true;
  String? token;
  Map<int, int> quantityChanges = {}; // Stocker les modifications de quantité

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  @override
  void dispose() {
    _updateCartOnExit(); // Envoyer les modifications lors de la sortie de la page
    super.dispose();
  }

  Future<void> _initializeCart() async {
    token = await TokenService.getToken();
    if (token == null) {
      print("Erreur: Token non disponible");
      return;
    }
    await fetchCart();
  }

  Future<Map<String, dynamic>?> getPendingInvoice() async {
    try {
      int? userId = await TokenService.getUserIdFromToken();

      final response =
          await apiService.get('$apiBaseUrl/invoices/?user_id=$userId');
      final invoices = response.data as List;

      final pendingInvoice = invoices.firstWhere(
        (invoice) => invoice['payment_status'] == 'PENDING',
        orElse: () => null,
      );

      if (pendingInvoice != null) {
        return {
          'id': pendingInvoice['id'],
          'total_amount': pendingInvoice['total_amount'],
        };
      } else {
        print("❌ Aucune facture PENDING trouvée");
        return null;
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération des factures : $e");
      return null;
    }
  }

  Future<void> fetchCart() async {
    try {
      int? userId = await TokenService.getUserIdFromToken();
      final response =
          await apiService.get('$apiBaseUrl/invoices/?user_id=$userId');

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final invoices = response.data as List;

        final pendingInvoice = invoices.firstWhere(
          (invoice) => invoice['payment_status'] == 'PENDING',
          orElse: () => {},
        );

        if (pendingInvoice.isNotEmpty) {
          setState(() {
            cartId = pendingInvoice["id"];
          });
          fetchCartItems();
        }
      }
    } catch (e) {
      print("Erreur lors de la récupération du panier: $e");
    }
  }

  Future<void> fetchCartItems() async {
    if (cartId == null) return;

    try {
      Response response =
          await apiService.get('$apiBaseUrl/invoices/items/$cartId');
      if (response.statusCode == 200) {
        List<dynamic> items = response.data;
        List<dynamic> detailedItems = [];
        Set<int> processedProductIds = {}; // Pour éviter les doublons

        for (var item in items) {
          int productId = item["product_id"];
          if (!processedProductIds.contains(productId)) {
            processedProductIds.add(productId);

            Response productResponse =
                await apiService.get('$apiBaseUrl/products/$productId');
            if (productResponse.statusCode == 200) {
              final productData = productResponse.data;
              detailedItems.add({
                "invoice_id": item["invoice_id"],
                "item_id": item["id"],
                "product_id": productId,
                "quantity": item["quantity"],
                "price_per_unit": item["price_per_unit"],
                "name": productData["name"],
                "price": productData["price"],
                "picture_url": productData["picture_url"],
              });
            }
          }
        }

        setState(() {
          cartItems = detailedItems;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des produits du panier: $e");
    }
  }

  void updateLocalCartItem(int itemId, int newQuantity) {
    setState(() {
      quantityChanges[itemId] = newQuantity;
      cartItems.firstWhere((item) => item["item_id"] == itemId)["quantity"] =
          newQuantity;
    });
  }

  Future<void> _updateCartOnExit() async {
    for (var entry in quantityChanges.entries) {
      int itemId = entry.key;
      int newQuantity = entry.value;
      var item = cartItems.firstWhere((item) => item["item_id"] == itemId);
      await updateCartItem(itemId, newQuantity, item["invoice_id"],
          item["product_id"], item["price_per_unit"]);
    }
  }

  Future<void> updateCartItem(int itemId, int quantity, int invoiceId,
      int productId, double pricePerUnit) async {
    if (quantity < 1) {
      removeFromCart(itemId);
      return;
    }
    try {
      await apiService.put('$apiBaseUrl/invoices/items/$itemId', {
        "invoice_id": invoiceId,
        "product_id": productId,
        "quantity": quantity,
        "price_per_unit": pricePerUnit
      });
    } catch (e) {
      print("Erreur lors de la mise à jour de l'article: $e");
    }
  }

  Future<void> removeFromCart(int itemId) async {
    try {
      Response response =
          await apiService.delete('$apiBaseUrl/invoices/items/$itemId');
      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item["item_id"] == itemId);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Produit supprimé !")));
      }
    } catch (e) {
      print("Erreur lors de la suppression du produit: $e");
    }
  }

  Future<String?> createPaypalOrder({
    required int invoiceId,
    required double amount,
    required List cartItems,
    required Map<String, dynamic> billingInfo,
  }) async {
    try {
      final response = await apiService.postWithHeaders(
        '/paypal/orders',
        data: {
          "invoice_id": invoiceId,
          "amount": amount,
          "cart": cartItems,
          "billing_info": billingInfo,
        },
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      final List<dynamic> links = data['links'];
      final approveLink = links.cast<Map<String, dynamic>>().firstWhere(
            (link) => link['rel'] == 'approve',
            orElse: () => <String, dynamic>{},
          )['href'];

      print("🧾 Order ID : ${data['id']}");
      print("🔗 Approve link : $approveLink");

      return approveLink;
    } catch (e) {
      print("Erreur lors de la création de la commande PayPal : $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> capturePaypalOrder(String orderId) async {
    try {
      final response = await apiService.postWithHeaders(
        '/paypal/orders/$orderId/capture',
        headers: {'Content-Type': 'application/json'},
      );
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;

      print("✅ Paiement capturé : $data");
      return data;
    } catch (e) {
      print("❌ Erreur capture PayPal : $e");
      return null;
    }
  }

  String? extractOrderId(String? approveUrl) {
    if (approveUrl == null) return null;

    final uri = Uri.parse(approveUrl);
    final token = uri.queryParameters['token'];
    return token; // PayPal place l'order_id ici
  }

  void launchPayment(BuildContext context, Map<String, dynamic> billingInfo,
      String montant) async {
    final invoice = await getPendingInvoice();

    if (invoice == null) {
      print("❌ Impossible de lancer le paiement sans facture");
      return;
    }

    final invoiceId = invoice['id'];
    final amount = double.tryParse(montant) ?? invoice['total_amount'];

    final approveUrl = await createPaypalOrder(
      billingInfo: billingInfo,
      amount: amount,
      invoiceId: invoiceId,
      cartItems: cartItems,
    );

    final orderId = extractOrderId(approveUrl);

    if (approveUrl != null && orderId != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaypalCheckoutPage(approveUrl: approveUrl),
        ),
      );

      if (result == true) {
        try {
          await apiService.put('$apiBaseUrl/invoices/$invoiceId', {
            "total_amount": amount,
            "payment_status": "PAID",
          });
        } catch (e) {
          print("Erreur lors de la mise à jour de l'article: $e");
        }

        final capturedData = await capturePaypalOrder(orderId);
        if (capturedData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NavigationBarWidget(
                  body: PaypalSuccessPage(data: capturedData)),
            ),
          );
        }
      } else {
        Navigator.pushNamed(context, '/paypal/cancel');
      }
    } else {
      print("Échec de création de commande PayPal");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Votre panier est vide."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final product = cartItems[index];
                          if (product["quantity"] > 0) {
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: ListTile(
                                leading: product["picture_url"] != null
                                    ? Image.network(
                                        product["picture_url"],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                    : const Icon(Icons.image),
                                title: Text(product["name"],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  "Quantité: ${product["quantity"]}\nPrix unité : ${product["price"]}€ \nPrix total: ${(double.parse(product["price"].toString()) * product["quantity"]).toStringAsFixed(2)}€",
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          removeFromCart(product["item_id"]),
                                    ),
                                    if (product["quantity"] > 1)
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.red),
                                        onPressed: () => updateLocalCartItem(
                                            product["item_id"],
                                            product["quantity"] - 1),
                                      ),
                                    if (product["quantity"] <= 1)
                                      const SizedBox(
                                        width: 48, // La largeur de l'icône
                                        child: Icon(Icons.remove,
                                            color: Colors.grey),
                                      ),
                                    Text("${product["quantity"]}"),
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.green),
                                      onPressed: () => updateLocalCartItem(
                                          product["item_id"],
                                          product["quantity"] + 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox
                                .shrink(); // Retourner un widget vide si la quantité est <= 0
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ${cartItems.fold<double>(0.0, (sum, item) => sum + (double.parse(item["price"].toString()) * item["quantity"])).toStringAsFixed(2)}€",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final totalAmount = cartItems.fold<double>(
                                0.0,
                                (sum, item) =>
                                    sum +
                                    (double.parse(item["price"].toString()) *
                                        item["quantity"]),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BillingFormPage(
                                    cartItems: cartItems,
                                    onValidated: (billingInfo) {
                                      launchPayment(
                                        context,
                                        billingInfo,
                                        totalAmount.toStringAsFixed(2),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: const Text('Accéder au paiement'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
