import 'package:flutter/material.dart';
import 'package:trinity_app/screens/scanner_screen.dart';
import 'api/token_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_screen.dart';
import 'screens/account_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/navigation_bar.dart';
import 'screens/cart_screen.dart';
import 'screens/order_screen.dart';

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
      title: 'Trinity Shop',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) => NavigationBarWidget(body: const HomeScreen()),
        "/product": (context) => NavigationBarWidget(body: ProductScreen()),
        "/order": (context) => NavigationBarWidget(body: const OrdersScreen()),
        "/account": (context) => NavigationBarWidget(body: const AccountScreen()),
        "/setting": (context) => NavigationBarWidget(body: const SettingScreen()),
        "/cart": (context) => NavigationBarWidget(body: CartScreen()),
        "/scanner": (context) => const ScannerScreen(),
      },
      // 🔁 Route dynamique pour /product/:barcode
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith("/product/")) {
          final barcode = settings.name!.split("/product/").last;
          return MaterialPageRoute(
            builder: (_) => NavigationBarWidget(
              body: ProductScreen(barcode: barcode),
            ),
          );
        }
        return null;
      },
    );
  }
}

