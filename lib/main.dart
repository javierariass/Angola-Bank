// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home_screen.dart';
import 'pages/login_page.dart';
import 'pages/questionnaire_page.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Sincronizar usuarios locales con Firestore antes de iniciar la app
  await syncLocalUsersWithFirestore();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _showLogin = false;
  bool _showHome = true;
  String _loggedUser = '';
  int _sessionQuizCount = 0;
  bool _sessionDocCreated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncUsers();
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(105, 209, 197, 1.0),
        ),
      ),
      home: Stack(
        children: [
          if (_showHome)
            HomeScreen(
              onNext: () {
                setState(() {
                  _showHome = false;
                  _showLogin = true;
                });
              },
            ),

          if (_showLogin)
            LoginPage(
              onLoginSuccess: (username) {
                setState(() {
                  _loggedUser = username;
                  _showLogin = false;
                  _sessionQuizCount = 0;
                  _sessionDocCreated = false;
                });
                // Sincronizar resultados pendentes após login
                tryUploadPendingResults();
                // Criar documento de sessão ao iniciar sessão
                createSessionDoc(username).then((_) {
                  setState(() {
                    _sessionDocCreated = true;
                  });
                });
              },
            ),
          if (!_showLogin && !_showHome && _loggedUser.isNotEmpty)
            AppHomeWrapper(onLogout: _handleLogout, loggedUser: _loggedUser),
        ],
      ),
      routes: {
        '/app_home':
            (context) => AppHomeWrapper(
              onLogout: _handleLogout,
              loggedUser: _loggedUser,
            ),
        '/questionnaire':
            (context) => QuestionnairePage(
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
      },
    );
  }
}

class AppHomeWrapper extends StatelessWidget {
  final Future<void> Function() onLogout;
  final String loggedUser;
  const AppHomeWrapper({
    super.key,
    required this.onLogout,
    required this.loggedUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Opções', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(
                    'Usuário: $loggedUser',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar dados'),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronização iniciada')),
                );
                // Sincronizar resultados pendientes
                final ok = await tryUploadPendingResults();
                // Sincronizar usuarios locales
                await syncLocalUsersWithFirestore();
                if (ok) {
                  // Eliminar registros locales si la sincronización fue exitosa
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('pending_results');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Sincronização completa! Dados locais eliminados e usuários atualizados.'
                          : 'Alguns dados não foram sincronizados.',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar registros locais'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('pending_results');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registros locais eliminados!')),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                await onLogout();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(title: const Text('Questionário Bancário')),
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
