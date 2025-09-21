import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final storage = FlutterSecureStorage();

Future<bool> login(String email, String password) async {
  final connectivity = await Connectivity().checkConnectivity();

  if (connectivity != ConnectivityResult.none) {
    // Online login
    final response = await http.post(
      Uri.parse('https://tu-api.com/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final passwordHash = sha256.convert(utf8.encode(password)).toString();

      await storage.write(key: 'jwt_token', value: token);
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'password_hash', value: passwordHash);

      return true;
    } else {
      return false;
    }
  } else {
    // Offline login
    final storedEmail = await storage.read(key: 'email');
    final storedHash = await storage.read(key: 'password_hash');
    final inputHash = sha256.convert(utf8.encode(password)).toString();

    return email == storedEmail && inputHash == storedHash;
  }
}

