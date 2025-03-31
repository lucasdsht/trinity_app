import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/token_service.dart';
import '../api/api_service.dart';
import 'productdetail_screen.dart';

class ProductDetailRouteScreen extends StatefulWidget {
  final String barcode;

  const ProductDetailRouteScreen({super.key, required this.barcode});

  @override
  State<ProductDetailRouteScreen> createState() => _ProductDetailRouteScreenState();
}

class _ProductDetailRouteScreenState extends State<ProductDetailRouteScreen> {
  Map<String, dynamic>? product;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final token = await TokenService.getToken();
      final dio = Dio(BaseOptions(baseUrl: apiBaseUrl, headers: {
        "Authorization": "Bearer $token",
      }));

      final response = await dio.get("/products/barcode/${widget.barcode}");

      if (response.statusCode == 200) {
        setState(() {
          product = response.data;
          isLoading = false;
        });
      } else {
        throw Exception("Produit introuvable");
      }
    } catch (e) {
      print("❌ Erreur chargement produit: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produit introuvable ou erreur serveur")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ProductDetailScreen(product: product!);
  }
}

