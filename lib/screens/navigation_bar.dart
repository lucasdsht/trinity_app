import 'package:flutter/material.dart';
import '../api/token_service.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget body;

  const NavigationBarWidget({super.key, required this.body});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int currentPageIndex = -1; // 🔥 -1 signifie aucune sélection par défaut

  final List<String> routes = [
    "/product",
    "/scanner",
    "/cart",
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute != null && routes.contains(currentRoute)) {
      setState(() {
        currentPageIndex = routes.indexOf(currentRoute);
      });
    } else {
      setState(() {
        currentPageIndex = -1; // ✅ Désactive la sélection dans la NavBar
      });
    }
  }

  void _onItemTapped(int index) {
    String newRoute = routes[index];

    if (ModalRoute.of(context)?.settings.name == newRoute) return;

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
      setState(() {
        currentPageIndex = -1; // ✅ Désactive la sélection
      });
      Navigator.pushNamedAndRemoveUntil(
          context, "/account", (route) => route.settings.name == "/home");
    }
  }

  Future<void> _onSettingsTapped() async {
    String? token = await TokenService.getToken();

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
    } else if (ModalRoute.of(context)?.settings.name != "/setting") {
      setState(() {
        currentPageIndex = -1; // ✅ Désactive la sélection
      });
      Navigator.pushNamedAndRemoveUntil(
          context, "/setting", (route) => route.settings.name == "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
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
            : null,
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              size: 35,
              color: ModalRoute.of(context)?.settings.name == "/account"
                  ? Colors.amber
                  : Colors.grey,
            ),
            onPressed: _onAccountTapped,
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 35,
              color: ModalRoute.of(context)?.settings.name == "/setting"
                  ? Colors.amber
                  : Colors.grey,
            ),
            onPressed: _onSettingsTapped,
          ),
        ],
      ),
      body: widget.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex:
            currentPageIndex >= 0 ? currentPageIndex : 0, // ✅ Correction ici
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.amber.withOpacity(0.3),
        destinations: [
          NavigationDestination(
            selectedIcon:
                Icon(Icons.store_mall_directory, size: 35, color: Colors.amber),
            icon: Icon(Icons.store_mall_directory_outlined,
                size: 35, color: Colors.grey),
            label: 'Produits',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.document_scanner, size: 35, color: Colors.amber),
            icon: Icon(Icons.document_scanner_outlined,
                size: 35, color: Colors.grey),
            label: 'Scanner',
          ),
          NavigationDestination(
            selectedIcon:
                Icon(Icons.shopping_cart, size: 35, color: Colors.amber),
            icon: Icon(Icons.shopping_cart_outlined,
                size: 35, color: Colors.grey),
            label: 'Panier',
          ),
        ],
      ),
    );
  }
}
