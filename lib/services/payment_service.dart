import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String clientId = 'Afh81FTgup_ufGcHnc5AiNXKvjGMc6A2CsOdftJ_XfD-wInNbqzivOFI5AdjROe4DZ6U5qjUho8wO-C_';
  static const String secret = 'EOwJJtaGgfFCkYzkpklHBw3oKTw9JHM_aOQFHWYl70TkYINXIYrvOA7aTNsCfyaeFe29wi1IPutFmLPW';

  static Future<String?> _getAccessToken() async {
    final credentials = base64.encode(utf8.encode('$clientId:$secret'));
    final url = Uri.parse('https://api.sandbox.paypal.com/v1/oauth2/token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $credentials',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print('Erreur lors de la récupération du token: ${response.statusCode}');
      return null;
    }
  }

  static Future<bool> processPayment() async {
    final String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print("Token d'accès non obtenu.");
      return false;
    }

    final url = Uri.parse("https://api.sandbox.paypal.com/v1/payments/payment");

    Map<String, dynamic> paymentBody = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {"total": "10.00", "currency": "EUR"},
          "description": "Achat via l'application mobile"
        }
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(paymentBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Paiement effectué avec succès !");

        // Récupération de l'ID du paiement
        var paymentId = jsonDecode(response.body)['id'];
        print("ID du paiement: $paymentId");

        // Vous pouvez ajouter ici l'appel pour exécuter le paiement sans redirection
        return true;
      } else {
        print("Erreur API PayPal: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception lors de l'appel à l'API PayPal: $e");
      return false;
    }
  }
}
