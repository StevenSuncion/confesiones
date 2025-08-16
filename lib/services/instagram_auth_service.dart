import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InstagramAuthService {
  static const String _appId = 'TU_APP_ID'; // Reemplaza con tu App ID
  static const String _appSecret = 'TU_APP_SECRET'; // Reemplaza con tu App Secret
  static const String _redirectUri = 'https://tudominio.com/auth'; // Tu URL de redirección
  
  // URL para iniciar el flujo de autenticación
  static String getAuthUrl() {
    return 'https://api.instagram.com/oauth/authorize'
        '?client_id=$_appId'
        '&redirect_uri=$_redirectUri'
        '&scope=user_profile,user_media'
        '&response_type=code';
  }
  
  // Intercambiar código por token de acceso
  static Future<String?> exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('https://api.instagram.com/oauth/access_token'),
      body: {
        'client_id': _appId,
        'client_secret': _appSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code': code,
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      await _saveToken(token);
      return token;
    }
    return null;
  }
  
  // Obtener información del usuario
  static Future<Map<String, dynamic>?> getUserInfo(String token) async {
    final response = await http.get(
      Uri.parse('https://graph.instagram.com/me?fields=id,username&access_token=$token'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
  
  // Guardar token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('instagram_token', token);
  }
  
  // Obtener token guardado
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('instagram_token');
  }
  
  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('instagram_token');
  }
}