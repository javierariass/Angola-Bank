import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'data/bank_questions.dart';
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
              child: Text('Opciones'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
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
              title: const Text('Sincronizar datos'),
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
                          ? '¡Datos sincronizados correctamente!'
                          : 'Algunos datos no se pudieron sincronizar. Se intentará de nuevo cuando haya conexión.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sin conexión. Los datos se subirán cuando exista conexión.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Cuestionario Bancario'),
        actions: [
          TextButton(
            onPressed: _toggleLogin,
            child: Text(
              _loggedIn ? 'Desloguear' : 'Loguear',
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
              child: const Text('Iniciar Cuestionario'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuizPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar datos'),
              onPressed: () async {
                final connected = await Connectivity().checkConnectivity() != ConnectivityResult.none;
                if (!mounted) return;
                if (connected) {
                  final ok = await tryUploadPendingResults();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? '¡Datos sincronizados correctamente!'
                          : 'Algunos datos no se pudieron sincronizar. Se intentará de nuevo cuando haya conexión.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sin conexión. Los datos se subirán cuando exista conexión.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  List<int?> selectedAnswers = List.filled(bankQuestions.length, null);

  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _totalTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _next() {
    if (selectedAnswers[currentQuestion] == null) return;
    if (currentQuestion < bankQuestions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _endTime = DateTime.now();
      _totalTime = _endTime!.difference(_startTime!);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Cuestionario finalizado!'),
          content: Text(
            'Gracias por completar el cuestionario.\n'
            'Tiempo total: ${_totalTime!.inMinutes} min ${_totalTime!.inSeconds % 60} seg',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                bool uploaded = true;
                try {
                  await uploadQuizResult(
                    answers: selectedAnswers,
                    startTime: _startTime!,
                    endTime: _endTime!,
                    totalTime: _totalTime!,
                  ).timeout(const Duration(seconds: 2));
                } catch (_) {
                  uploaded = false;
                }
                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Espera un frame para que el HomePage esté montado
                await Future.delayed(const Duration(milliseconds: 100));
                // Usa el context global del HomePage para mostrar el AlertDialog
                final homeContext = rootNavigatorKey.currentState?.context;
                if (homeContext != null) {
                  showDialog(
                    context: homeContext,
                    builder: (_) => AlertDialog(
                      title: Text(uploaded
                          ? '¡Datos subidos correctamente!'
                          : 'Sin conexión'),
                      content: Text(uploaded
                          ? 'Tus respuestas fueron guardadas en la nube.'
                          : 'Los datos se subirán automáticamente cuando exista conexión.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(homeContext).pop(),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Volver al inicio'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = bankQuestions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregunta ${currentQuestion + 1}/${bankQuestions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.question, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ...List.generate(question.options.length, (i) {
              return RadioListTile<int>(
                title: Text(question.options[i]),
                value: i,
                groupValue: selectedAnswers[currentQuestion],
                onChanged: (val) {
                  setState(() {
                    selectedAnswers[currentQuestion] = val;
                  });
                },
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedAnswers[currentQuestion] != null ? _next : null,
              child: Text(
                currentQuestion == bankQuestions.length - 1
                    ? 'Finalizar'
                    : 'Siguiente',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
