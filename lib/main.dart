import 'package:flutter/material.dart';
import 'api/token_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await TokenService.getToken();

  runApp(MyApp(initialRoute: token != null ? "/home" : "/login"));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      home: const NavigationExample(),
      routes: {
        "/login": (context) => LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => HomeScreen(),
      },
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationBar();
}

class _NavigationBar extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trinity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 35),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestion du compte')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.store_mall_directory_outlined, size: 35),
            icon: Icon(
              Icons.store_mall_directory_outlined,
              size: 35,
            ),
            label: 'Produits',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.document_scanner_outlined, size: 35),
            icon: Icon(Icons.document_scanner_outlined, size: 35),
            label: 'Scanner',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.local_offer_outlined, size: 35),
            icon: Icon(Icons.local_offer_outlined, size: 35),
            label: 'Promotion',
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
