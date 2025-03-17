// Tests unitaires pour le ViewModel
import 'package:flutter_test/flutter_test.dart';
import 'package:trinity_app/billing_viewmodel.dart'; 

void main() {
  test('BillingViewModel.processPayment returns a bool', () async {
    final viewModel = BillingViewModel();
    final result = await viewModel.processPayment();
    expect(result, isA<bool>());
  });
}


