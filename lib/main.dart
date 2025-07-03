import 'package:flutter/material.dart';
import 'services/internet_checked.dart';
import 'data/bank_questions.dart';
import 'pages/config_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _connected = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initConnectivityListener((msg, connected) {
        if (mounted) {
          setState(() {
            _connected = connected;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    disposeConnectivityListener();
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
        child: ElevatedButton(
          child: const Text('Iniciar Cuestionario'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(
                  connected: _connected,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final bool connected;
  const QuizPage({super.key, required this.connected});

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
    _startTime = DateTime.now(); // Guarda la hora de inicio al entrar
  }

  void _next() {
    if (selectedAnswers[currentQuestion] == null) return;
    if (currentQuestion < bankQuestions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      _endTime = DateTime.now(); // Guarda la hora de finalización
      _totalTime = _endTime!.difference(_startTime!); // Calcula el tiempo total

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Cuestionario finalizado!'),
          content: Text(
            'Gracias por completar el cuestionario.\n'
            'Hora de inicio: ${_startTime!.toLocal()}\n'
            'Hora de fin: ${_endTime!.toLocal()}\n'
            'Tiempo total: ${_totalTime!.inMinutes} min ${_totalTime!.inSeconds % 60} seg',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
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
