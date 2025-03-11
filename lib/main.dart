import 'package:flutter/material.dart';
import 'api/token_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/account_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/navigation_bar.dart';

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
      home: NavigationExample(
        body: const HomeScreen(), // 🔥 Ajout du paramètre `body`
      ),
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => RegisterScreen(),
        "/home": (context) =>
            NavigationExample(body: const HomeScreen()), // 🔥 Correction ici
        "/account": (context) =>
            NavigationExample(body: const AccountScreen()), // 🔥 Correction ici
        "/setting": (context) =>
            NavigationExample(body: const SettingScreen()), // 🔥 Correction ici
      },
    );
  }
}
