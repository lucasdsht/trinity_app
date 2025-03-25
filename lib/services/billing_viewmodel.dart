// View-Modèle : la logique métier et la gestion des données
import 'payment_service.dart';

class BillingViewModel {
  // Variables pour stocker les informations de facturation
  String? firstName;
  String? lastName;
  String? address;
  String? zipCode;
  String? city;

  /// Cette méthode délègue la logique de paiement au PaymentService.
  Future<bool> processPayment() async {
    return await PaymentService.processPayment();
  }
}
