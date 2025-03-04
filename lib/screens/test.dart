import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trinity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 35),
            onPressed: () {
              Navigator.pushNamed(context, "/account");
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 35),
            onPressed: () {
              Navigator.pushNamed(context, "/setting");
            },
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
        indicatorColor: Colors.amber,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.store_mall_directory_outlined, size: 35),
            icon: Icon(Icons.store_mall_directory_outlined, size: 35),
            label: 'Produits',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.document_scanner_outlined, size: 35),
            icon: Icon(Icons.document_scanner_outlined, size: 35),
            label: 'Scanner',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.shopping_cart_outlined, size: 35),
            icon: Icon(Icons.shopping_cart_outlined, size: 35),
            label: 'Panier',
          ),
        ],
      ),
    );
  }
}
