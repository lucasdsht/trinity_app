import 'package:flutter/material.dart';
import './test.dart'; // Assure-toi d'avoir le bon chemin

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
        child: Text('👤 Page de paramètre', style: TextStyle(fontSize: 24)),
      ),
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}
