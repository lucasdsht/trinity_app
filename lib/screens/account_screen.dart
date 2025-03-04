import 'package:flutter/material.dart';
import './test.dart'; // Assure-toi d'avoir le bon chemin

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/product");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/scanner");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/cart");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: const Center(
        child: Text('👤 Page Compte', style: TextStyle(fontSize: 24)),
      ),
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}
