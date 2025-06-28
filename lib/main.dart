import 'package:flutter/material.dart';
import 'services/internet_checked.dart';
import 'widgets/rating_app.dart';
import 'data/bank_questions.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  void _next() {
    if (selectedAnswers[currentQuestion] == null) return;
    if (currentQuestion < bankQuestions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RatingScreen(
            answers: selectedAnswers,
            connected: widget.connected,
          ),
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

class RatingScreen extends StatefulWidget {
  final List<int?> answers;
  final bool connected;
  const RatingScreen({super.key, required this.answers, required this.connected});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double? _rating;

  void _onRatingChanged(double rating) {
    setState(() {
      _rating = rating;
    });

    // --- Lógica para guardar en base de datos local ---
    // TODO: Guardar widget.answers y _rating en base de datos local aquí

    // --- Lógica para enviar si hay conexión ---
    if (widget.connected) {
      // TODO: Enviar datos a servidor o base de datos remota aquí
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('¡Gracias!'),
          content: Text('Tus respuestas y calificación han sido guardadas.\n'
              'Rating: ${_rating?.toStringAsFixed(1) ?? ''} estrellas'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Cerrar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Califica la app')),
      body: Center(
        child: StarRating(
          initialRating: 4.0,
          onRatingChanged: _onRatingChanged,
        ),
      ),
    );
  }
}
