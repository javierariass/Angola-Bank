// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'pages/questionnaire_page.dart';
import 'pages/config_page.dart';
import 'services/firebase_service.dart';

// GlobalKey para mostrar diálogos desde cualquier parte
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loggedIn = false;
  late final StreamSubscription<ConnectivityResult> _connSub;

  @override
  void initState() {
    super.initState();
    _connSub = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        final ok = await tryUploadPendingResults();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? '¡Datos sincronizados automáticamente!'
                : 'Algunos datos no se pudieron sincronizar. Se intentará de nuevo cuando haya conexión.'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _connSub.cancel();
    super.dispose();
  }

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
            const DrawerHeader(
              child: Text('Opções'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuração'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConfigPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar dados'),
              onTap: () async {
                Navigator.pop(context);
                final connected = await Connectivity().checkConnectivity() != ConnectivityResult.none;
                if (!mounted) return;
                if (connected) {
                  final ok = await tryUploadPendingResults();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Dados sincronizados automaticamente!'
                          : 'Alguns dados não puderam ser sincronizados. Será tentado novamente quando houver conexão.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sem conexão. Os dados serão enviados quando houver conexão.'),
                    ),
                  );
                }
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuestionnairePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

