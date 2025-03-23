import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:trinity_app/api/api_service.dart';
import '../api/token_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();
  String? originalEmail;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      int? userId = await TokenService.getUserIdFromToken();
      if (userId == null) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      final response = await Dio().get(
        "$apiBaseUrl/users/$userId",
        options: Options(
          headers: {"Authorization": "Bearer ${await TokenService.getToken()}"},
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
          isLoading = false;

          firstNameController.text = userData?['first_name'] ?? "";
          lastNameController.text = userData?['last_name'] ?? "";
          emailController.text = userData?['email'] ?? "";
          phoneController.text = userData?['phone_number'] ?? "";
          addressController.text = userData?['billing_address'] ?? "";
          zipController.text = userData?['zip_code'] ?? "";
          cityController.text = userData?['city'] ?? "";
          countryController.text = userData?['country'] ?? "";

          originalEmail = userData?['email'];
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

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      int? userId = await TokenService.getUserIdFromToken();
      if (userId == null) return;

      final response = await Dio().put(
        "$apiBaseUrl/users/$userId",
        options: Options(
          headers: {"Authorization": "Bearer ${await TokenService.getToken()}"},
        ),
        data: {
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "email": emailController.text,
          "phone_number": phoneController.text,
          "billing_address": addressController.text,
          "zip_code": zipController.text,
          "city": cityController.text,
          "country": countryController.text,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = response.data;
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Informations mises à jour avec succès")),
        );

        if (originalEmail != emailController.text) {
          _logoutAndShowDialog();
        }
      } else {
        setState(() {
          errorMessage = "Impossible de mettre à jour les informations.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de mise à jour : ${e.toString()}";
      });
    }
  }

  Future<void> _logoutAndShowDialog() async {
    await TokenService.removeToken();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Email modifié"),
          content: const Text(
              "Votre email a été modifié. Veuillez vous reconnecter."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        "👤 Mon Profil",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildEditableField("Prénom", firstNameController),
                      _buildEditableField("Nom", lastNameController),
                      _buildEditableField("Email", emailController),
                      _buildEditableField("Téléphone", phoneController),
                      _buildEditableField("Adresse", addressController),
                      _buildEditableField("Code Postal", zipController),
                      _buildEditableField("Ville", cityController),
                      _buildEditableField("Pays", countryController),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout),
                              label: const Text("Se déconnecter"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (isEditing) {
                                  _updateUserData();
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
                              },
                              icon: Icon(isEditing ? Icons.save : Icons.edit),
                              label:
                                  Text(isEditing ? "Enregistrer" : "Modifier"),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextFormField(
          controller: controller,
          enabled: isEditing,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: (value) =>
              value == null || value.isEmpty ? "Ce champ est requis" : null,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
