import 'package:flutter/material.dart';
import 'api/token_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
//import 'screens/test_payment_page.dart'; // Import de la page de test

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? token = await TokenService.getToken();

  // Pour lancer directement la page de test, décommentez la ligne suivante et commentez la suivante.
 // runApp(MyApp(initialRoute: "/test"));

  
  runApp(MyApp(initialRoute: token != null ? "/home" : "/login"));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/home": (context) => const HomeScreen(),
        "/test": (context) => const TestPaymentPage(), // Route pour le test manuel
      },
    );
  }
}