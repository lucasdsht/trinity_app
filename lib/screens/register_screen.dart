import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      final response = await Dio().post(
        '$apiBaseUrl/auth/register',
        data: {
          "first_name": _firstNameController.text,
          "last_name": _lastNameController.text,
          "email": _emailController.text,
          "phone_number": _phoneNumberController.text,
          "billing_address": _billingAddressController.text,
          "zip_code": _zipCodeController.text,
          "city": _cityController.text,
          "country": _countryController.text,
          "password": _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: 10),
              TextField(controller: _lastNameController, decoration: InputDecoration(labelText: "Last Name", border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _phoneNumberController, decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(controller: _billingAddressController, decoration: InputDecoration(labelText: "Billing Address", border: OutlineInputBorder())),
              SizedBox(height: 10),TextField(controller: _zipCodeController, decoration: InputDecoration(labelText: "Zip Code", border: OutlineInputBorder())),
              SizedBox(height: 10),TextField(controller: _cityController, decoration: InputDecoration(labelText: "City", border: OutlineInputBorder())),
              SizedBox(height: 10),TextField(controller: _countryController, decoration: InputDecoration(labelText: "Country", border: OutlineInputBorder())),
              SizedBox(height: 10),TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
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
      ),
    );
  }
}
