import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      final response = await Dio().post(
        '$apiBaseUrl/api/register',
        data: {
          "email": _emailController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, "/login");
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Registration Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: _register, child: Text("Register")),
            TextButton(
                onPressed: () => Navigator.pushNamed(context, "/login"),
                child: Text("Already have an account? Login")),
          ],
        ),
      ),
    );
  }
}
