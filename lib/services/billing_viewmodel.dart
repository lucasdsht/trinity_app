import 'payment_service.dart';

class BillingViewModel {
  // Variables pour stocker les informations de facturation
  String? firstName;
  String? lastName;
  String? address;
  String? zipCode;
  String? city;

  // Liste dynamique des articles dans le panier
  List<CartItem> cartItems = [];

  // Méthode pour initialiser le panier avec des articles
  void setCartItems(List<CartItem> items) {
    cartItems = items; // Met à jour le panier avec les articles donnés
  }

  // Cette méthode délègue la logique de paiement au PaymentService.
  Future<bool> processPayment() async {
    // Passer les informations de facturation et du panier au PaymentService
    bool paymentSuccess = await PaymentPage.createPayment(
      cartItems: cartItems,
      firstName: firstName,
      lastName: lastName,
      address: address,
      zipCode: zipCode,
      city: city,
    );

    // Retourne le résultat du paiement
    return paymentSuccess;
  }

  // Méthode pour calculer le montant total du panier
  double get totalAmount {
    return PaymentPage.calculateTotal(cartItems);
  }
}
