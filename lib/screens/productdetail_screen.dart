import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../api/token_service.dart';


class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);



  Color QuantiteColor(int stock) {
    switch (stock) {
      case 0:
        return Colors.red;
      case > 0 && < 10 :
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<bool> isProductInCart(int productId, int invoiceId) async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return false;

      final response = await Dio().get(
        '$apiBaseUrl/invoices/items/$invoiceId',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        List<dynamic> items = response.data;

        // Vérifier si le produit est dans le panier avec une quantité >= 1
        return items.any((item) => item["product_id"] == productId && item["quantity"] >= 1);
      }
    } catch (e) {
      print("Erreur lors de la vérification du produit dans le panier: $e");
    }

    return false; // Retourne false en cas d'erreur
  }

  Future<int> createOrGetInvoice() async {
    int invoiceId = 0;
    try {
      String? token = await TokenService.getToken();
      if (token == null) return 0;

      final dio = Dio();
      final getResponse = await dio.get(
        '$apiBaseUrl/invoices/?user_id=${await TokenService.getUserIdFromToken()}',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (getResponse.statusCode == 200 && getResponse.data.isNotEmpty) {
        invoiceId = getResponse.data[0]["id"];
        return invoiceId;
      } else {
        final postResponse = await dio.post(
          '$apiBaseUrl/invoices/',
          data: {
            "user_id": await TokenService.getUserIdFromToken(),
            "total_amount": 0,
            "payment_status": "PENDING"
          },
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
        invoiceId = postResponse.data["id"];
        return invoiceId;
      }
    } catch (e) {
      print("Erreur lors de la récupération de la facture: $e");
    }
    return 0;
  }

  Future<void> _addToCart(int productId, double price, int invoiceId) async {
    if (invoiceId == null) return;
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      await Dio().post(
        '$apiBaseUrl/invoices/items/',
        data: {
          "invoice_id": invoiceId,
          "product_id": productId,
          "quantity": 1,
          "price_per_unit": price,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("Erreur d'ajout au panier: $e");
    }
  }

  Future<void> ajouterAuPanier() async {
      int id_invoice = await createOrGetInvoice();
      await _addToCart(product["id"], product["price"], id_invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product["name"])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: product["picture_url"] != null
                  ? Image.network(
                product["picture_url"],
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
              )
                  : const Icon(Icons.image, size: 100),
            ),
             const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nom : ${product["name"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Marque : ${product["brand"]}", style: const TextStyle(fontSize: 18)),
                    Text("Catégorie : ${product["category"]}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Prix : \$${product["price"].toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 8),
                    Text("Quantité en stock : ${product["stock_quantity"]}", style: TextStyle(fontSize: 18, color: QuantiteColor(product["stock_quantity"]))),
                    const SizedBox(height: 8),
                    Text("Informations nutritionnelles : ", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    product["nutritional_information"] != null && product["nutritional_information"].isNotEmpty
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (product["nutritional_information"] as Map<String, dynamic>).entries.map((entry) {
                        return Text("${entry.key} : ${entry.value}");
                      }).toList(),
                    )
                        : const Text("Aucune information nutritionnelle disponible."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if(Navigator.canPop(context)){
                      Navigator.pop(context, true); // Revenir à la page précédente et signaler un changement
                    }

                  },
                  child: const Text("Retour")
                ),
                FutureBuilder<int>(
                  future: createOrGetInvoice(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Text("Erreur");
                    } else {
                      return FutureBuilder<bool>(
                          future: isProductInCart(product["id"], snapshot.data!),
                          builder: (context, isInCartSnapshot) {
                            return ElevatedButton(
                              onPressed: isInCartSnapshot.data == true
                                  ? null
                                  : () async {
                                      await _addToCart(product["id"], product["price"], snapshot.data!);
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))); // Rafraîchit la page
                                    },
                              child: Text(isInCartSnapshot.data == true ? "Déjà ajouté" : "Ajouter au panier"),
                            );
                          });
                    }
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
