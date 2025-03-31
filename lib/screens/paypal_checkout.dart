import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalCheckoutPage extends StatelessWidget {
  final String approveUrl;
  final String returnUrl = "https://example.com/paypal/success";
  final String cancelUrl = "https://example.com/paypal/cancel";

  const PaypalCheckoutPage({super.key, required this.approveUrl});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final url = request.url;

          if (url.contains("/paypal/success")) {
            Navigator.pop(context, true);
            return NavigationDecision.prevent;
          }

          if (url.contains("/paypal/cancel")) {
            Navigator.pop(context, false);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(approveUrl));

    return Scaffold(
      appBar: AppBar(title: const Text("Paiement PayPal")),
      body: WebViewWidget(controller: controller),
    );
  }
}
