import 'package:flutter/material.dart';
import '../api/token_service.dart';
import 'package:dio/dio.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        "http://10.0.2.2:8000/users/",
        queryParameters: {"limit": 5}, // 🔥 Mets ici l'URL correcte de ton API
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Impossible de récupérer les informations.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion : ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Compte")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "👤 Mon Profil",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // 🔥 Affichage des infos de l'utilisateur
                      _buildUserInfo("Nom",
                          "${userData?['first_name']} ${userData?['last_name']}"),
                      _buildUserInfo("Email", userData?['email']),
                      _buildUserInfo("Téléphone", userData?['phone_number']),
                      _buildUserInfo("Adresse", userData?['billing_address']),
                      _buildUserInfo("Code Postal", userData?['zip_code']),
                      _buildUserInfo("Ville", userData?['city']),
                      _buildUserInfo("Pays", userData?['country']),
                      _buildUserInfo("ID", userData?['id'].toString()),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text("Se déconnecter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // 🔥 Fonction pour construire chaque ligne d'information utilisateur
  Widget _buildUserInfo(String label, String? value) {
    return value != null && value.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const Divider(), // Ligne de séparation
            ],
          )
        : const SizedBox.shrink(); // 🔥 Cache la section si la valeur est null
  }
}
