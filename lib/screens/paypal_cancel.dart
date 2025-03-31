import 'package:flutter/material.dart';

class PaypalCancelPage extends StatelessWidget {
  const PaypalCancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text("Paiement annulé par l'utilisateur",
                style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
