import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Représente un article dans le panier
class CartItem {
  String name;
  double price;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Calcul du prix total pour cet article (prix * quantité)
  double get totalPrice => price * quantity;
}

class PaymentPage {
  /// Méthode pour calculer le montant total du panier
  static double calculateTotal(List<CartItem> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      total += item.totalPrice; // Additionner le prix total de chaque article
    }
    return total; // Retourne le montant total
  }

  /// Méthode pour effectuer le paiement
  static Future<bool> createPayment({
    required List<CartItem> cartItems, // Liste des articles dans le panier
    String? firstName,
    String? lastName,
    String? address,
    String? zipCode,
    String? city,
  }) async {
    bool paymentStatus = false;

    // Calculer le montant total du panier
    double totalAmount = calculateTotal(cartItems);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-payment'), // Endpoint backend
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'address': address,
          'zipCode': zipCode,
          'city': city,
          'totalAmount': totalAmount, // Envoie le montant total calculé
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Si la réponse du backend est un succès, le paiement est réussi
        paymentStatus = true;
      } else {
        paymentStatus = false; // En cas d'échec du paiement
      }
    } catch (e) {
      print("Erreur réseau : $e");
      paymentStatus = false; // En cas d'erreur réseau
    }

    return paymentStatus; // Retourner l'état du paiement
  }
}
