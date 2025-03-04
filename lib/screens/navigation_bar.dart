import 'package:flutter/material.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationBar();
}

class _NavigationBar extends State<NavigationExample> {
  int currentPageIndex = 0;

  final List<String> routes = [
    "/product",
    "/scanner",
    "/promotion",
    "/cart",
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentPageIndex = index;
    });

    Navigator.pushNamed(context, routes[index]);
  }

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
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
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
