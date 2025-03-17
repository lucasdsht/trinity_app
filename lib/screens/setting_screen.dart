import 'package:flutter/material.dart';
import '../api/token_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = false; // 🔥 Mode sombre activé/désactivé
  bool notificationsEnabled = true; // 🔥 Notifications activées par défaut

  /// 🔹 Fonction pour gérer la déconnexion
  Future<void> _logout() async {
    await TokenService.removeToken();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            "⚙️ Paramètres",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// 🔹 Section Notifications
          SwitchListTile(
            title: const Text("Notifications"),
            subtitle: Text(notificationsEnabled ? "Activées" : "Désactivées"),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications, color: Colors.orange),
          ),

          /// 🔹 Section Mode Sombre
          SwitchListTile(
            title: const Text("Mode Sombre"),
            subtitle: Text(isDarkMode ? "Activé" : "Désactivé"),
            value: isDarkMode,
            onChanged: (bool value) {
              setState(() {
                isDarkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode, color: Colors.grey),
          ),

          /// 🔹 Section Aide
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.green),
            title: const Text("Centre d'aide"),
            subtitle: const Text("Obtenir de l'aide et du support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.pushNamed(context, "/help");
            },
          ),

          /// 🔹 Bouton de déconnexion
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
    );
  }
}
