import 'package:flutter/material.dart';
import '../utils/login_offline.dart';

class LoginPage extends StatefulWidget {
  final Function(String username) onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() { _loading = true; _error = null; });
    final user = _userController.text.trim();
    final pass = _passController.text;
    final ok = await login(user, pass);
    if (ok) {
      widget.onLoginSuccess(user);
    } else {
      setState(() { _error = "Usuario o contraseña incorrectos"; });
    }
    setState(() { _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Iniciar sesión", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _userController,
                  decoration: const InputDecoration(labelText: "Usuario"),
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passController,
                  decoration: const InputDecoration(labelText: "Contraseña"),
                  obscureText: true,
                  enabled: !_loading,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading ? const CircularProgressIndicator() : const Text("Entrar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
