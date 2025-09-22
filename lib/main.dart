// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/questionnaire_page.dart';
import 'pages/config_page.dart';
import 'pages/login_page.dart';
import 'services/firebase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _showLogin = false;
  String _loggedUser = '';
  int _sessionQuizCount = 0;
  bool _sessionDocCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncUsers();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLogin = true;
      });
    });
  }

  Future<void> _handleLogout() async {
    // Sincronizar el registro local de la sesión actual si existe
    if (_loggedUser.isNotEmpty && _sessionDocCreated) {
      await trySyncLocalCurrentSessionDoc(_loggedUser);
    }
    setState(() {
      _loggedUser = '';
      _showLogin = true;
      _sessionQuizCount = 0;
      _sessionDocCreated = false;
    });
  }

  Future<void> _syncUsers() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Questionário Bancário',
      home: Stack(
        children: [
          const HomeScreen(),
          if (_showLogin)
            LoginPage(
              onLoginSuccess: (username) {
                setState(() {
                  _loggedUser = username;
                  _showLogin = false;
                  _sessionQuizCount = 0;
                  _sessionDocCreated = false;
                });
                // Crear documento de sesión al iniciar sesión
                createSessionDoc(username).then((_) {
                  setState(() {
                    _sessionDocCreated = true;
                  });
                });
              },
            ),
          if (!_showLogin && _loggedUser.isNotEmpty)
            AppHomeWrapper(
              onLogout: _handleLogout,
              loggedUser: _loggedUser,
            ),
        ],
      ),
      routes: {
        '/app_home': (context) => AppHomeWrapper(
          onLogout: _handleLogout,
          loggedUser: _loggedUser,
        ),
        '/questionnaire': (context) => QuestionnairePage(
          loggedUser: _loggedUser,
          sessionQuizCount: _sessionQuizCount,
          onSessionQuizCountChanged: (newCount) {
            setState(() {
              _sessionQuizCount = newCount;
            });
            // Actualizar el contador en el documento de sesión actual
            if (_loggedUser.isNotEmpty && _sessionDocCreated) {
              updateCurrentSessionQuizCount(_loggedUser, newCount);
            }
          },
        ),
        '/config': (context) => const ConfigPage(),
      },
    );
  }
}

class AppHomeWrapper extends StatelessWidget {
  final Future<void> Function() onLogout;
  final String loggedUser;
  const AppHomeWrapper({super.key, required this.onLogout, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Opções')),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuração'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/config');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar dados'),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronização iniciada')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await onLogout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Questionário Bancário'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('Usuario: $loggedUser')),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Iniciar Questionário'),
              onPressed: () {
                Navigator.pushNamed(context, '/questionnaire');
              },
            ),
          ],
        ),
      ),
    );
  }
}
