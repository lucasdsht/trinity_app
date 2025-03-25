import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;
  String paymentStatus = '';

  // Méthode pour effectuer le paiement
  Future<void> createPayment() async {
    setState(() {
      isLoading = true;
      paymentStatus = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-payment'), // Endpoint backend
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // Pas besoin de paramètres supplémentaires ici
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          paymentStatus = 'Paiement réussi !\n${data['paymentDetails']}';
        });
      } else {
        setState(() {
          paymentStatus = 'Erreur lors du paiement. Veuillez réessayer.';
        });
      }
    } catch (e) {
      setState(() {
        paymentStatus = 'Erreur réseau : $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement PayPal'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: createPayment,
                    child: Text('Effectuer le paiement'),
                  ),
                  SizedBox(height: 20),
                  Text(paymentStatus),
                ],
              ),
      ),
    );
  }
}
