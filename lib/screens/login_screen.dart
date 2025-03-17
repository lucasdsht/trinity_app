import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/token_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // Vérification que les champs ne sont pas vides
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Dio().post(
        'http://10.0.2.2:8000/auth/login',
        data: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        },
      );

      // Vérification de la réponse API
      if (response.statusCode == 200 && response.data["access_token"] != null) {
        await TokenService.saveToken(response.data["access_token"]);

        // 🔹 Supprime `/login` de l'historique et redirige vers `/home`
        Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identifiants invalides")),
        );
      }
    } on DioException catch (e) {
      String errorMessage = "Échec de la connexion";

      if (e.response != null && e.response!.statusCode != null) {
        errorMessage =
            "Erreur ${e.response!.statusCode}: ${e.response!.statusMessage}";
      } else if (e.message != null) {
        errorMessage = "Problème réseau: ${e.message}";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Se connecter"),
                  ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
