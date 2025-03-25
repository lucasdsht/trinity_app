import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:dio/dio.dart';
import '../api/token_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String? barcode;

  @override
  void initState() {
    super.initState();
    _startScanner(); // démarre dès que l’écran est ouvert
  }

  Future<void> _startScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (result != null && result != "-1") {
      setState(() => barcode = result);
      await _handleProduct(result);
    } else {
      Navigator.pop(context); // Retour si annulé
    }
  }

  Future<void> _handleProduct(String barcode) async {
    final dio = Dio();
    final token = await TokenService.getToken();

    dio.options.headers["Authorization"] = "Bearer $token";

    try {
      final response = await dio.get('$apiBaseUrl/products');

      if (response.statusCode == 200) {
        final List<dynamic> products = response.data;

        final found = products.any((p) => p["barcode"] == barcode);

        if (!found) {
          await dio.post('/products', data: {
            "barcode": barcode,
          });
        }

        // Redirige vers la page produit
        Navigator.pushReplacementNamed(context, '/product/$barcode');
      }
    } catch (e) {
      print("❌ Erreur : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors du traitement du produit")),
      );
      Navigator.pop(context); // retour en cas d’erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

