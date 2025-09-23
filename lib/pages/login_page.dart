import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

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
    final ok = await validateLocalUserLogin(user, pass);
    if (ok) {
      widget.onLoginSuccess(user);
    } else {
  setState(() { _error = "Usuário ou senha incorretos"; });
    }
    setState(() { _loading = false; });
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entrar")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Iniciar sessão", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(labelText: "Usuário"),
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passController,
                          decoration: const InputDecoration(labelText: "Senha"),
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
            ),
          );
        },
      ),
    );
  }
}
