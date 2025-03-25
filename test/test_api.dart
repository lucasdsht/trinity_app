// test/test_api.dart
import '../lib/services/payment_service.dart';

void main() async {
  print("Test de l'API PayPal en Sandbox");
  bool result = await PaymentService.processPayment();
  print("Résultat du paiement : $result");
}
