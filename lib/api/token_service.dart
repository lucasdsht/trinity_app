import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static const String _tokenKey = "jwt_token";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<int?> getUserIdFromToken() async {
    String? token = await TokenService.getToken(); // Récupère le token stocké
    if (token == null) return null;

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken["user_id"]; // 🔥 Vérifie le bon nom de la clé
    } catch (e) {
      print("Erreur de décodage du token: $e");
      return null;
    }
  }

  void main() async {
    int? userId = await getUserIdFromToken();
    print("User ID: $userId");
  }
}
