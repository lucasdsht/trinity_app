import 'package:flutter/material.dart';
import '../api/token_service.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget body;

  const NavigationBarWidget({super.key, required this.body});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int currentPageIndex = 0;

  final List<String> routes = [
    "/product",
    "/scanner",
    "/cart",
  ];

  void _onItemTapped(int index) {
    String newRoute = routes[index];

    if (ModalRoute.of(context)?.settings.name == newRoute) {
      return;
    }

    setState(() {
      currentPageIndex = index;
    });

    Navigator.pushReplacementNamed(context, newRoute);
  }

  Future<void> _onAccountTapped() async {
    String? token = await TokenService.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else if (ModalRoute.of(context)?.settings.name != "/account") {
      Navigator.pushNamedAndRemoveUntil(
          context, "/account", (route) => route.settings.name == "/home");
    }
  }

  Future<void> _onSettingsTapped() async {
    String? token = await TokenService.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else if (ModalRoute.of(context)?.settings.name != "/setting") {
      Navigator.pushNamedAndRemoveUntil(
          context, "/setting", (route) => route.settings.name == "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentRoute = ModalRoute.of(context)?.settings.name ?? "/product";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trinity Shop'),
        leading: ModalRoute.of(context)?.settings.name != "/home"
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/home", (route) => false);
                },
              )
            : null, // 🔥 Cache la flèche si on est déjà sur HomeScreen
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 35,
              color: currentRoute == "/account" ? Colors.amber : Colors.grey,
            ),
            onPressed: _onAccountTapped,
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 35,
              color: currentRoute == "/setting" ? Colors.amber : Colors.grey,
            ),
            onPressed: _onSettingsTapped,
          ),
        ],
      ),
      body: widget.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.transparent,
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
