import 'package:flutter/material.dart';
import '../api/token_service.dart';

class NavigationBarWidget extends StatefulWidget {
  final Widget body;

  const NavigationBarWidget({super.key, required this.body});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int currentPageIndex = -1;

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
        currentPageIndex = -1;
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
        currentPageIndex = -1;
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
        currentPageIndex = -1;
      });
      Navigator.pushNamedAndRemoveUntil(
          context, "/setting", (route) => route.settings.name == "/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '🛍 Trinity Shop',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 3,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: ModalRoute.of(context)?.settings.name != "/home"
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
              size: 30,
              color: ModalRoute.of(context)?.settings.name == "/account"
                  ? Colors.amber
                  : Colors.grey,
            ),
            onPressed: _onAccountTapped,
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 28,
              color: ModalRoute.of(context)?.settings.name == "/setting"
                  ? Colors.amber
                  : Colors.grey,
            ),
            onPressed: _onSettingsTapped,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: widget.body,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: currentPageIndex < 0
              ? Colors.transparent
              : Colors.amber.withOpacity(0.3),
          backgroundColor: Colors.white,
          elevation: 2,
          labelTextStyle: MaterialStateProperty.all(const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: currentPageIndex < 0 ? 0 : currentPageIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            NavigationDestination(
              icon: Icon(
                currentPageIndex == 0
                    ? Icons.store_mall_directory
                    : Icons.store_mall_directory_outlined,
                size: 28,
                color: currentPageIndex == 0 ? Colors.amber : Colors.grey,
              ),
              label: 'Produits',
            ),
            NavigationDestination(
              icon: Icon(
                currentPageIndex == 1
                    ? Icons.document_scanner
                    : Icons.document_scanner_outlined,
                size: 28,
                color: currentPageIndex == 1 ? Colors.amber : Colors.grey,
              ),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(
                currentPageIndex == 2
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
                size: 28,
                color: currentPageIndex == 2 ? Colors.amber : Colors.grey,
              ),
              label: 'Panier',
            ),
          ],
        ),
      ),
    );
  }
}
