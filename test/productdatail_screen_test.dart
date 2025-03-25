import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/token_service.dart';
import 'package:trinity_app/screens/productdetail_screen.dart';

import 'productdatail_screen.mocks.dart';

@GenerateMocks([Dio, TokenService])
void main() {
  late MockDio mockDio;
  late MockTokenService mockTokenService;

  setUp(() {
    mockDio = MockDio();
    mockTokenService = MockTokenService();
  });

  final product = {
    "id": 1,
    "name": "Produit Test",
    "brand": "Marque Test",
    "category": "Catégorie Test",
    "price": 10.0,
    "stock_quantity": 5,
    "picture_url": null,
    "nutritional_information": {"Calories": "100 kcal"}
  };

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ProductDetailScreen(product: product),
    );
  }

  testWidgets(
      'Affichage des informations du produit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Nom : Produit Test'), findsOneWidget);
    expect(find.text('Marque : Marque Test'), findsOneWidget);
    expect(find.text('Catégorie : Catégorie Test'), findsOneWidget);
    expect(find.text('Prix : \$10.00'), findsOneWidget);
    expect(find.text('Quantité en stock : 5'), findsOneWidget);
    expect(find.text('Calories : 100 kcal'), findsOneWidget);
  });
}
