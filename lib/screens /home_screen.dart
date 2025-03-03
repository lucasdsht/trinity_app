import 'package:flutter/material.dart';
import '../api/token_service.dart';

class HomeScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: ElevatedButton(onPressed: () => logout(context), child: Text("Logout")),
      ),
    );
  }
}

