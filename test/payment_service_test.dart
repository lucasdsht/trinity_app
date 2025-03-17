// Tests unitaires pour le Service de paiement
import 'package:flutter_test/flutter_test.dart';
import 'package:trinity_app/payment_service.dart'; // Utilisation du nom correct

void main() {
  test('PaymentService.processPayment returns a bool', () async {
    final result = await PaymentService.processPayment();
    expect(result, isA<bool>());
  });
}


