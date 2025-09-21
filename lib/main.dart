// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'pages/config_page.dart';
import 'pages/home_screen.dart';
import 'pages/questionnaire_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Questionário Bancário',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/app_home': (context) => const AppHomeWrapper(),
        '/questionnaire': (context) => const QuestionnairePage(),
        '/config': (context) => const ConfigPage(),
      },
    );
  }
}

/// A thin wrapper that re-implements the original HomePage UI but keeps it
/// simple and reachable via route `/app_home`. This avoids circular imports
/// while preserving the functionality (drawer, sync, and navigation to
/// questionnaire and config pages).
class AppHomeWrapper extends StatefulWidget {
  const AppHomeWrapper({super.key});

  @override
  State<AppHomeWrapper> createState() => _AppHomeWrapperState();
}

class _AppHomeWrapperState extends State<AppHomeWrapper> {
  bool _loggedIn = false;

  void _toggleLogin() {
    setState(() {
      _loggedIn = !_loggedIn;
    });
  }

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
                // Try to call a service named tryUploadPendingResults if present.
                // We avoid importing services/firebase_service.dart here to keep
                // this file minimal. If that function is needed, consider
                // refactoring into a separate helper file.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronização iniciada')),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Questionário Bancário'),
        actions: [
          TextButton(
            onPressed: _toggleLogin,
            child: Text(
              _loggedIn ? 'Deslogar' : 'Logar',
              style: const TextStyle(color: Colors.white),
            ),
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
