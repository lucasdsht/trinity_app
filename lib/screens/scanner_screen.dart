import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String? barcode;

  Future<void> _startScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (result != null && result != "-1") {
      setState(() => barcode = result);
      Navigator.pushReplacementNamed(context, '/product/$result');
    } else {
      Navigator.pop(context); // Retour si annulé
    }
  }

  @override
  void initState() {
    super.initState();
    _startScanner(); // démarre dès que l’écran est ouvert
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

