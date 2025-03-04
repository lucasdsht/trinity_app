import 'package:flutter/material.dart';
import '../api/token_service.dart';
import './test.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> logout(BuildContext context) async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/product");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/scanner");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/cart");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section "Produits Conseillés"
            const Text(
              "🔹 Produits Conseillés",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Voir pour afficher les produits conseillés
            const SizedBox(height: 20),

            // Section "Produits en Promotion"
            const Text(
              "🔥 Produits en Promotion",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            // Voir pour afficher les produits en promotion
          ],
        ),
      ),
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}
