import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import './navigation_bar.dart';
import './home_screen.dart';

class PaypalSuccessPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaypalSuccessPage({super.key, required this.data});

  void generatePdfReceipt(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    final payer = data['payer'];
    final payerEmail = payer?['email_address'] ?? 'Inconnu';
    final capture = data['purchase_units']?[0]?['payments']?['captures']?[0];
    final amount = capture?['amount']?['value'] ?? '?';
    final currency = capture?['amount']?['currency_code'] ?? '';
    final transactionId = capture?['id'] ?? '–';
    final status = capture?['status'] ?? '–';
    final date = capture?['create_time'] ?? DateTime.now().toString();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Reçu de paiement PayPal",
                style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 20),
            pw.Text("Transaction ID : $transactionId"),
            pw.Text("Date : $date"),
            pw.Text("Montant : $amount $currency"),
            pw.Text("Statut : $status"),
            pw.Text("Email du client : $payerEmail"),
            pw.SizedBox(height: 40),
            pw.Text("Merci pour votre commande 🛒",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "reçu_paypal.pdf",
    );
  }

  @override
  Widget build(BuildContext context) {
    final payer = data['payer'];
    final payerEmail = payer?['email_address'] ?? 'Inconnu';
    final capture = data['purchase_units']?[0]?['payments']?['captures']?[0];
    final amount = capture?['amount']?['value'] ?? '?';
    final currency = capture?['amount']?['currency_code'] ?? '';
    final transactionId = capture?['id'] ?? '–';
    final status = capture?['status'] ?? '–';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              Text("Transaction : $transactionId",
                  style: const TextStyle(fontSize: 16)),
              Text("Montant : $amount $currency",
                  style: const TextStyle(fontSize: 16)),
              Text("Statut : $status", style: const TextStyle(fontSize: 16)),
              Text("Client : $payerEmail",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text("Télécharger le reçu"),
                onPressed: () => generatePdfReceipt(data),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            NavigationBarWidget(body: const HomeScreen())),
                    (route) => false,
                  );
                },
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
