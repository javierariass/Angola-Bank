import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/advanced_questions.dart';

// ------------------ Fondo animado ------------------
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({required this.child, super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset> _lines = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _generateLines();
  }

  void _generateLines() {
    final random = Random();
    _lines = List.generate(
      20,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _LinesPainter(_lines, _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class _LinesPainter extends CustomPainter {
  final List<Offset> lines;
  final double progress;
  _LinesPainter(this.lines, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blueAccent.withOpacity(
            0.1,
          ) // <-- Cambiar color aquí si quieres
          ..strokeWidth = 1.5;

    for (var i = 0; i < lines.length; i++) {
      final start = Offset(
        (lines[i].dx + progress * 0.5) % 1 * size.width,
        (lines[i].dy + progress * 0.5) % 1 * size.height,
      );
      final end = Offset(
        (lines[i].dx + progress * 0.5 + 0.05) % 1 * size.width,
        (lines[i].dy + progress * 0.5 + 0.05) % 1 * size.height,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ------------------ QuestionnairePage ------------------
class QuestionnairePage extends StatefulWidget {
  final String loggedUser;
  final int sessionQuizCount;
  final Function(int newCount)? onSessionQuizCountChanged;
  final Map<String, dynamic>? answers;
  const QuestionnairePage({
    super.key,
    required this.loggedUser,
    required this.sessionQuizCount,
    this.onSessionQuizCountChanged,
    this.answers,
  });

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  late final Map<String, dynamic> answers;
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _totalTime;
  int _localSessionQuizCount = 0;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    answers = widget.answers ?? {};
    _startTime = DateTime.now();
    _localSessionQuizCount = widget.sessionQuizCount;

    // Inicializar sliders y bancos dinámicos
    for (final q in advancedQuestions) {
      if (q.type == QuestionType.scale && answers[q.id] == null) {
        answers[q.id] = q.scaleMin ?? 1;
      }
    }
  }

  // ------------------ Métodos originales ------------------
  bool _isCurrentAnswered() {
    final page = _questionnairePages[_currentPage];
    if (page is AdvancedQuestion) {
      final val = answers[page.id];
      if (page.type == QuestionType.text) {
        return val != null && val.toString().isNotEmpty;
      } else if (page.type == QuestionType.multipleChoice) {
        return val != null && (val is List) && val.isNotEmpty;
      } else if (page.type == QuestionType.singleChoice) {
        return val != null;
      } else if (page.type == QuestionType.scale) {
        return val != null;
      }
    } else if (page is Map && page['type'] == 'sentiment') {
      final keyPos = '${page['id']}_${page['banco']}_positivo';
      final keyNeg = '${page['id']}_${page['banco']}_negativo';
      final keyTxt = '${page['id']}_${page['banco']}_texto';
      return answers[keyPos] != null &&
          answers[keyNeg] != null &&
          answers[keyTxt] != null &&
          answers[keyTxt].toString().isNotEmpty;
    } else if (page is Map) {
      final key = '${page['id']}_${page['banco']}';
      final val = answers[key];
      if (page['type'] == QuestionType.text) {
        return val != null && val.toString().isNotEmpty;
      } else if (page['type'] == QuestionType.multipleChoice) {
        return val != null && (val is List) && val.isNotEmpty;
      } else if (page['type'] == QuestionType.scale) {
        return val != null;
      }
    }
    return false;
  }

  void _submit() async {
    _endTime = DateTime.now();
    _totalTime = _endTime!.difference(_startTime!);
    final answersRow = _formatAnswersForRow();
    final result = {
      'answers': answersRow,
      'user': widget.loggedUser,
      'startTime': _startTime?.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'totalTimeSeconds': _totalTime?.inSeconds,
    };
    await _saveQuizResultLocal(result);
    if (!mounted) return;
    setState(() {
      _localSessionQuizCount++;
    });
    if (widget.onSessionQuizCountChanged != null) {
      widget.onSessionQuizCountChanged!(_localSessionQuizCount);
    }
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Questionário finalizado!'),
            content: Text(
              'Obrigado por completar o questionário.\nTempo total: ${_totalTime!.inMinutes} min ${_totalTime!.inSeconds % 60} seg\nSincronização: Pendente',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
    );
  }

  Future<void> _saveQuizResultLocal(Map<String, dynamic> row) async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_results') ?? [];
    pending.add(jsonEncode(row));
    await prefs.setStringList('pending_results', pending);
  }

  List<String> _missingQuestions() {
    // Tu código original de validación de respuestas
    return [];
  }

  Map<String, dynamic> _formatAnswersForRow() {
    // Tu código original para formatear respuestas
    return {};
  }

  List<dynamic> get _questionnairePages {
    // Tu código original que construye las páginas incluyendo dinámicas por banco
    return advancedQuestions;
  }

  // ------------------ Build adaptado ------------------
  @override
  Widget build(BuildContext context) {
    final totalPages = _questionnairePages.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionário Bancário'),
        centerTitle: true,
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalPages,
                  onPageChanged: (i) {
                    setState(() {
                      _currentPage = i;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _questionnairePages[index];
                    Widget questionWidget;

                    // ------------------ AdvancedQuestionWidget completo ------------------
                    if (page is AdvancedQuestion) {
                      questionWidget = AdvancedQuestionWidget(
                        question: page,
                        answer: answers[page.id],
                        onChanged: (val) {
                          setState(() {
                            answers[page.id] = val;
                          });
                        },
                        answers: answers,
                      );
                    } else if (page is Map && page['type'] == 'sentiment') {
                      final keyPos = '${page['id']}_${page['banco']}_positivo';
                      final keyNeg = '${page['id']}_${page['banco']}_negativo';
                      final keyTxt = '${page['id']}_${page['banco']}_texto';
                      questionWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page['question'],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text('Sentimento Positivo:'),
                          Slider(
                            min: 0,
                            max: 10,
                            divisions: 10,
                            value: (answers[keyPos] ?? 0).toDouble(),
                            label: (answers[keyPos] ?? 0).toString(),
                            onChanged: (val) {
                              setState(() {
                                answers[keyPos] = val.round();
                              });
                            },
                          ),
                          Text('Sentimento Negativo:'),
                          Slider(
                            min: 0,
                            max: 10,
                            divisions: 10,
                            value: (answers[keyNeg] ?? 0).toDouble(),
                            label: (answers[keyNeg] ?? 0).toString(),
                            onChanged: (val) {
                              setState(() {
                                answers[keyNeg] = val.round();
                              });
                            },
                          ),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Explique o sentimento',
                            ),
                            onChanged: (val) {
                              setState(() {
                                answers[keyTxt] = val;
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      questionWidget = const SizedBox.shrink();
                    }

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SingleChildScrollView(
                        key: ValueKey(index),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Pergunta ${index + 1} de $totalPages',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 10),
                                questionWidget,
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        overlayColor: MaterialStateProperty.all(
                          Colors.blue.withOpacity(0.2),
                        ),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.fastOutSlowIn,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                    ),
                  if (_currentPage < totalPages - 1)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        overlayColor: MaterialStateProperty.all(
                          Colors.blue.withOpacity(0.2),
                        ),
                      ),
                      onPressed:
                          _isCurrentAnswered()
                              ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.fastOutSlowIn,
                                );
                              }
                              : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Próxima'),
                    ),
                  if (_currentPage == totalPages - 1)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        overlayColor: MaterialStateProperty.all(
                          const Color.fromRGBO(33, 243, 89, 1).withOpacity(0.2),
                        ),
                      ),
                      onPressed: () {
                        final missing = _missingQuestions();
                        if (missing.isEmpty) {
                          _submit();
                        }
                      },
                      child: const Text('Finalizar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentPage + 1) / totalPages,
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ AdvancedQuestionWidget completo ------------------
class AdvancedQuestionWidget extends StatefulWidget {
  final AdvancedQuestion question;
  final dynamic answer;
  final Function(dynamic) onChanged;
  final bool showNext;
  final Map<String, dynamic> answers;
  const AdvancedQuestionWidget({
    required this.question,
    required this.answer,
    required this.onChanged,
    required this.answers,
    this.showNext = false,
    super.key,
  });

  @override
  State<AdvancedQuestionWidget> createState() => _AdvancedQuestionWidgetState();
}

class _AdvancedQuestionWidgetState extends State<AdvancedQuestionWidget> {
  dynamic _localAnswer;

  @override
  void initState() {
    super.initState();
    _localAnswer = widget.answer;
  }

  @override
  void didUpdateWidget(covariant AdvancedQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.answer != widget.answer) {
      _localAnswer = widget.answer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    switch (q.type) {
      case QuestionType.singleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 18)),
            if (q.options.isNotEmpty)
              ...List.generate(q.options.length, (i) {
                return RadioListTile<int>(
                  title: Text(q.options[i]),
                  value: i,
                  groupValue: _localAnswer,
                  onChanged: (val) {
                    setState(() {
                      _localAnswer = val;
                    });
                    widget.onChanged(val);
                  },
                );
              }),
            if (q.allowOther && _localAnswer == q.options.length - 1)
              ListTile(
                title: const Text('Outro (especificar)'),
                subtitle: TextField(
                  onChanged: (val) {
                    widget.onChanged({'outro': val});
                    final key = '${q.id}_Outro';
                    widget.answers[key] = val;
                  },
                ),
              ),
          ],
        );
      case QuestionType.multipleChoice:
        List<int> selected = (_localAnswer ?? <int>[]).cast<int>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 18)),
            ...List.generate(q.options.length, (i) {
              return CheckboxListTile(
                title: Text(q.options[i]),
                value: selected.contains(i),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _localAnswer ??= <int>[];
                      if (!_localAnswer.contains(i)) _localAnswer.add(i);
                    } else {
                      _localAnswer.remove(i);
                    }
                    widget.onChanged(_localAnswer);
                  });
                },
              );
            }),
            if (q.allowOther && selected.contains(q.options.length - 1))
              ListTile(
                title: const Text('Outro (especificar)'),
                subtitle: TextField(
                  onChanged: (val) {
                    widget.onChanged({'outro': val});
                    final key = '${q.id}_Outro';
                    widget.answers[key] = val;
                  },
                ),
              ),
          ],
        );
      case QuestionType.scale:
        int min = q.scaleMin ?? 1;
        int max = q.scaleMax ?? 5;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 18)),
            Slider(
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              value: (_localAnswer ?? min).toDouble(),
              label: (_localAnswer ?? min).toString(),
              onChanged: (val) {
                setState(() {
                  _localAnswer = val.round();
                });
                widget.onChanged(_localAnswer);
              },
            ),
            Text('Valor: ${_localAnswer ?? min}'),
          ],
        );
      case QuestionType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 18)),
            TextField(
              onChanged: (val) {
                setState(() {
                  _localAnswer = val;
                });
                widget.onChanged(val);
              },
            ),
          ],
        );
    }
  }
}
