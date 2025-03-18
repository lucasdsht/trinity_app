import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/api_service.dart';
import '../api/token_service.dart';
import 'order_detail_screen.dart';
import 'navigation_bar.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  /// 🔹 Récupère les commandes depuis l'API
  Future<void> _fetchOrders() async {
    try {
      int? userId = await TokenService.getUserIdFromToken();
      if (userId == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }
      String? token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        '$apiBaseUrl/invoices/', // Remplace avec ton URL API correcte
        queryParameters: {"user_id": userId},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = response.data; // Liste des commandes
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Impossible de récupérer les commandes.";
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

  /// 🔹 Convertit le statut de paiement en couleur
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
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : orders.isEmpty
                  ? const Center(
                      child: Text("Aucune commande trouvée.",
                          style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.receipt_long,
                                color:
                                    _getStatusColor(order["payment_status"])),
                            title: Text("Commande #${order["id"]}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Montant total: ${order["total_amount"].toString()} €"),
                                Text("Statut: ${order["payment_status"]}",
                                    style: TextStyle(
                                        color: _getStatusColor(
                                            order["payment_status"]))),
                                Text(
                                    "Date: ${DateTime.parse(order["created_at"]).toLocal()}"),
                              ],
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 18),

                            /// 🔹 **Ajout du onTap ici !**
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigationBarWidget(
                                      body: OrderDetailScreen(
                                          order:
                                              order)), // ✅ Envoie la commande
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
