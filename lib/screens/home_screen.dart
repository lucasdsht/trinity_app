import 'package:flutter/material.dart';
import '../api/token_service.dart';

class HomeScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => logout(context),
              child: const Text("Logout"),
            ),
            SizedBox(
              height: 50,
            ),
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.account_circle_outlined)),
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.shopping_cart)),
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.document_scanner_outlined)),
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.local_offer_outlined)),
            IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.store_mall_directory_outlined)),
          ],
        ),
      ),
    );
  }
}

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: const Text('Hello, World!'),
    );
  }
}
