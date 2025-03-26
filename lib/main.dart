import 'package:flutter/material.dart';
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
import 'screens/paypal_success.dart';
import 'screens/paypal_cancel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService.removeToken();
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
      home: NavigationBarWidget(
        body: const HomeScreen(),
      ),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/order": (context) => NavigationBarWidget(body: const OrdersScreen()),
        "/register": (context) => RegisterScreen(),
        "/product": (context) => NavigationBarWidget(body: ProductScreen()),
        "/home": (context) => NavigationBarWidget(body: const HomeScreen()),
        "/account": (context) =>
            NavigationBarWidget(body: const AccountScreen()),
        "/setting": (context) =>
            NavigationBarWidget(body: const SettingScreen()),
        "/cart": (context) => NavigationBarWidget(body: CartScreen()),
        '/paypal/success': (context) =>
            NavigationBarWidget(body: PaypalSuccessPage(data: {})),
        '/paypal/cancel': (context) =>
            NavigationBarWidget(body: PaypalCancelPage()),
      },
    );
  }
}
