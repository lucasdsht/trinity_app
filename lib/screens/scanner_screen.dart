import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startScanner()); // 🧠 avoids initState rebuild issue
  }

  Future<void> _startScanner() async {
    if (_hasScanned) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleBarcodeScannerPage()),
    );

    if (result != null && result != "-1") {
      setState(() => _hasScanned = true);

      // ✅ Go to product route
      Navigator.pushReplacementNamed(context, '/product/$result');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

