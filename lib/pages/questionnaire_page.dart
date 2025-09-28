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
      duration: const Duration(seconds: 30),
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
          ..color = const Color.fromRGBO(105, 209, 197, 1.0).withOpacity(0.1)
          ..strokeWidth = 5.5;

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

  @override
  void initState() {
    super.initState();
    answers = widget.answers ?? {};
    _startTime = DateTime.now();
    _localSessionQuizCount = widget.sessionQuizCount;
    // Set default value for all scale questions (including dinámicas)
    for (final q in advancedQuestions) {
      if (q.type == QuestionType.scale && answers[q.id] == null) {
        answers[q.id] = q.scaleMin ?? 1;
      }
    }
    // Para preguntas dinámicas por banco
    final q2 = advancedQuestions.firstWhere(
      (q) => q.id == 'q02',
      orElse:
          () => AdvancedQuestion(
            id: '',
            question: '',
            type: QuestionType.singleChoice,
          ),
    );
    final q2val = answers['q02'];
    List<int> indices = (q2val is List) ? q2val.cast<int>() : <int>[];
    List<String> bancosQ2 = [];
    for (var i in indices) {
      if (i >= 0 && i < q2.options.length) {
        if (i == q2.options.length - 1) {
          // Outro
          final outroText = answers['q02_Outro'];
          if (outroText != null && outroText.toString().trim().isNotEmpty) {
            bancosQ2.add(outroText.toString().trim());
          }
        } else {
          bancosQ2.add(q2.options[i]);
        }
      }
    }
    for (final banco in bancosQ2) {
      // q13: scale 0-10
      final key13 = 'q13_$banco';
      if (answers[key13] == null) answers[key13] = 0;
      // Sentiment sliders (por defecto mínimo)
      final key12pos = 'q12_${banco}_positivo';
      final key12neg = 'q12_${banco}_negativo';
      if (answers[key12pos] == null) answers[key12pos] = 0;
      if (answers[key12neg] == null) answers[key12neg] = 0;
    }
    // Para sliders de preguntas fijas
    for (final page in _questionnairePages) {
      if (page is AdvancedQuestion && page.type == QuestionType.scale) {
        if (answers[page.id] == null) answers[page.id] = page.scaleMin ?? 1;
      } else if (page is Map && page['type'] == QuestionType.scale) {
        final key = '${page['id']}_${page['banco']}';
        if (answers[key] == null) answers[key] = page['scaleMin'] ?? 0;
      }
    }
  }

  Map<String, dynamic> _formatAnswersForRow() {
    final Map<String, dynamic> row = {};
    // Preguntas generales (no por banco)
    for (final q in advancedQuestions) {
      if (["q09", "q10", "q12", "q13", "q14"].contains(q.id)) continue;
      final val = answers[q.id];
      if (val == null ||
          (q.type == QuestionType.text && val.toString().isEmpty))
        continue;
      if (q.type == QuestionType.multipleChoice) {
        // Guardar los textos seleccionados
        if (val is List) {
          row[q.id] =
              val
                  .map(
                    (i) =>
                        (i is int && i >= 0 && i < q.options.length)
                            ? q.options[i]
                            : i,
                  )
                  .toList();
        } else {
          row[q.id] = val;
        }
        if (q.allowOther && val is List && val.contains(q.options.length - 1)) {
          final outroText = answers['${q.id}_Outro'];
          if (outroText != null && outroText.toString().isNotEmpty) {
            row['${q.id}_Outro'] = outroText;
          }
        }
      } else if (q.type == QuestionType.singleChoice) {
        // Guardar el texto seleccionado
        if (val is int && val >= 0 && val < q.options.length) {
          row[q.id] = q.options[val];
        } else {
          row[q.id] = val;
        }
        if (q.allowOther && val == q.options.length - 1) {
          final outroText = answers['${q.id}_Outro'];
          if (outroText != null && outroText.toString().isNotEmpty) {
            row['${q.id}_Outro'] = outroText;
          }
        }
      } else if (q.type == QuestionType.scale) {
        row[q.id] = val;
      } else if (q.type == QuestionType.text) {
        row[q.id] = val;
      }
    }

    // Bancos seleccionados en q2
    final q2 = advancedQuestions.firstWhere(
      (q) => q.id == 'q02',
      orElse:
          () => AdvancedQuestion(
            id: '',
            question: '',
            type: QuestionType.singleChoice,
          ),
    );
    final q2val = answers['q02'];
    List<int> indices = (q2val is List) ? q2val.cast<int>() : <int>[];
    List<String> bancosQ2 = [];
    for (var i in indices) {
      if (i >= 0 && i < q2.options.length) {
        if (i == q2.options.length - 1) {
          final outroText = answers['q02_Outro'];
          if (outroText != null && outroText.toString().trim().isNotEmpty) {
            bancosQ2.add(outroText.toString().trim());
          }
        } else {
          bancosQ2.add(q2.options[i]);
        }
      }
    }

    // Preguntas dinámicas agrupadas por banco
    final Map<String, dynamic> bancos = {};
    for (final banco in bancosQ2) {
      final Map<String, dynamic> bancoAnswers = {};
      // q09
      final key09 = 'q09_$banco';
      final val09 = answers[key09];
      if (val09 is List) {
        bancoAnswers['q09'] =
            val09
                .map(
                  (i) =>
                      (i is int &&
                              i >= 0 &&
                              i < advancedQuestions[8].options.length)
                          ? advancedQuestions[8].options[i]
                          : i,
                )
                .toList();
      } else {
        bancoAnswers['q09'] = val09 ?? [];
      }
      // q10
      final key10 = 'q10_$banco';
      final val10 = answers[key10];
      if (val10 is List) {
        bancoAnswers['q10'] =
            val10
                .map(
                  (i) =>
                      (i is int &&
                              i >= 0 &&
                              i < advancedQuestions[9].options.length)
                          ? advancedQuestions[9].options[i]
                          : i,
                )
                .toList();
      } else {
        bancoAnswers['q10'] = val10 ?? [];
      }
      // q12 (sentiment)
      final key12pos = 'q12_${banco}_positivo';
      final key12neg = 'q12_${banco}_negativo';
      final key12txt = 'q12_${banco}_texto';
      bancoAnswers['q12'] = {
        'positivo': answers[key12pos] ?? 0,
        'negativo': answers[key12neg] ?? 0,
        'texto': answers[key12txt] ?? '',
      };
      // q13
      final key13 = 'q13_$banco';
      bancoAnswers['q13'] = answers[key13] ?? 0;
      // q14
      final key14 = 'q14_$banco';
      bancoAnswers['q14'] = answers[key14] ?? '';
      bancos[banco] = bancoAnswers;
    }
    row['bancos'] = bancos;
    return row;
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
              'Obrigado por completar o questionário.\n'
              'Tempo total: ${_totalTime!.inMinutes} min ${_totalTime!.inSeconds % 60} seg\n'
              'Sincronização: Pendente',
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
    // Save quiz result locally for later sync
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_results') ?? [];
    pending.add(jsonEncode(row));
    await prefs.setStringList('pending_results', pending);
  }

  List<String> _missingQuestions() {
    final missing = <String>[];
    final pages = _questionnairePages;
    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      String id;
      String label;
      if (page is AdvancedQuestion) {
        id = page.id;
        label = page.question;
        final val = answers[id];
        if (page.type == QuestionType.text) {
          if (val == null || val.toString().isEmpty)
            missing.add('P${i + 1}: $label');
        } else if (page.type == QuestionType.multipleChoice) {
          if (val == null || (val is List && val.isEmpty))
            missing.add('P${i + 1}: $label');
        } else if (page.type == QuestionType.singleChoice) {
          if (val == null) missing.add('P${i + 1}: $label');
        } else if (page.type == QuestionType.scale) {
          if (val == null) missing.add('P${i + 1}: $label');
        }
      } else if (page is Map && page['type'] == 'sentiment') {
        final keyPos = '${page['id']}_${page['banco']}_positivo';
        final keyNeg = '${page['id']}_${page['banco']}_negativo';
        final keyTxt = '${page['id']}_${page['banco']}_texto';
        if (answers[keyPos] == null)
          missing.add('P${i + 1}: Sentimento positivo para ${page['banco']}');
        if (answers[keyNeg] == null)
          missing.add('P${i + 1}: Sentimento negativo para ${page['banco']}');
        if (answers[keyTxt] == null || answers[keyTxt].toString().isEmpty)
          missing.add(
            'P${i + 1}: Explicação do sentimento para ${page['banco']}',
          );
      } else if (page is Map) {
        final key = '${page['id']}_${page['banco']}';
        label = page['question'];
        if (page['type'] == QuestionType.text) {
          if (answers[key] == null || answers[key].toString().isEmpty)
            missing.add('P${i + 1}: $label');
        } else if (page['type'] == QuestionType.multipleChoice) {
          if (answers[key] == null ||
              (answers[key] is List && (answers[key] as List).isEmpty))
            missing.add('P${i + 1}: $label');
        } else if (page['type'] == QuestionType.scale) {
          if (answers[key] == null) missing.add('P${i + 1}: $label');
        }
      }
    }
    return missing;
  }

  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> get _dynamicBankPages {
    // Get bancos seleccionados en Q2
    final q2 = advancedQuestions.firstWhere(
      (q) => q.id == 'q02',
      orElse:
          () => AdvancedQuestion(
            id: '',
            question: '',
            type: QuestionType.singleChoice,
          ),
    );
    final q2val = answers['q02'];
    List<int> indices = (q2val is List) ? q2val.cast<int>() : <int>[];
    List<String> bancosQ2 = [];
    for (var i in indices) {
      if (i >= 0 && i < q2.options.length) {
        if (i == q2.options.length - 1) {
          // Outro
          final outroText = answers['q02_Outro'];
          if (outroText != null && outroText.toString().trim().isNotEmpty) {
            bancosQ2.add(outroText.toString().trim());
          }
        } else {
          bancosQ2.add(q2.options[i]);
        }
      }
    }
    // Para cada banco, crear las preguntas 9, 10, 12, 13, 14
    List<Map<String, dynamic>> pages = [];
    for (final banco in bancosQ2) {
      pages.add({
        'id': 'q09',
        'banco': banco,
        'type': QuestionType.multipleChoice,
        'options': advancedQuestions[8].options,
        'question': 'Que serviços utiliza em "$banco"?',
      });
      pages.add({
        'id': 'q10',
        'banco': banco,
        'type': QuestionType.multipleChoice,
        'options': advancedQuestions[9].options,
        'question': 'Que produtos utiliza em "$banco"?',
      });
      pages.add({
        'id': 'q12',
        'banco': banco,
        'type': 'sentiment', // tipo especial para dos sliders y texto
        'question':
            'Análise de sentimento positivo ou negativo para "$banco"? Por quê?',
      });
      pages.add({
        'id': 'q13',
        'banco': banco,
        'type': QuestionType.scale,
        'scaleMin': 0,
        'scaleMax': 10,
        'question':
            'Em uma escala de 0 a 10, qual é a probabilidade de recomendar "$banco" a um amigo ou colega?',
      });
      pages.add({
        'id': 'q14',
        'banco': banco,
        'type': QuestionType.text,
        'question': 'Qual a principal razão desta recomendação para "$banco"?',
      });
    }
    return pages;
  }

  List<dynamic> get _questionnairePages {
    // Preguntas fijas: 1-8, 11, 15-19
    List<dynamic> pages = [];
    // Agregar preguntas fijas: 0-7 (q01-q08)
    for (var i = 0; i <= 7; i++) {
      pages.add(advancedQuestions[i]);
    }
    // Insertar preguntas dinámicas después de la 8
    pages.addAll(_dynamicBankPages);
    // Agregar pregunta fija q11 (índice 10)
    pages.add(advancedQuestions[10]);
    // Agregar preguntas fijas q15-q19 (índices 14-18)
    for (var i = 14; i < advancedQuestions.length; i++) {
      pages.add(advancedQuestions[i]);
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _questionnairePages.length;
    return AnimatedBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Questionário Bancário'),
          centerTitle: true,
        ),
        body: Padding(
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
                    if (page is AdvancedQuestion) {
                      // Q03 opciones dinámicas
                      if (page.id == 'q03') {
                        final q2 = advancedQuestions.firstWhere(
                          (q) => q.id == 'q02',
                          orElse:
                              () => AdvancedQuestion(
                                id: '',
                                question: '',
                                type: QuestionType.singleChoice,
                              ),
                        );
                        List<int> indices =
                            (answers['q02'] ?? <int>[]) is List
                                ? (answers['q02'] as List).cast<int>()
                                : <int>[];
                        List<String> bancosQ2 = [
                          for (var i in indices)
                            if (i >= 0 && i < q2.options.length) q2.options[i],
                        ];
                        if (!bancosQ2.contains('Outro')) bancosQ2.add('Outro');
                        questionWidget = AdvancedQuestionWidget(
                          question: AdvancedQuestion(
                            id: page.id,
                            question: page.question,
                            type: page.type,
                            options: bancosQ2,
                            allowOther: true,
                          ),
                          answer: answers[page.id],
                          onChanged: (val) {
                            setState(() {
                              answers[page.id] = val;
                            });
                          },
                          answers: answers,
                        );
                      } else {
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
                      }
                    } else if (page is Map && page['type'] == 'sentiment') {
                      // Pregunta 12 especial: dos sliders y texto
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
                    } else if (page is Map) {
                      // Preguntas 9,10,13,14 por banco
                      final key = '${page['id']}_${page['banco']}';
                      if (page['type'] == QuestionType.multipleChoice) {
                        questionWidget = AdvancedQuestionWidget(
                          question: AdvancedQuestion(
                            id: key,
                            question: page['question'],
                            type: page['type'],
                            options: page['options'],
                          ),
                          answer: answers[key],
                          onChanged: (val) {
                            setState(() {
                              answers[key] = val;
                            });
                          },
                          answers: answers,
                        );
                      } else if (page['type'] == QuestionType.scale) {
                        questionWidget = AdvancedQuestionWidget(
                          question: AdvancedQuestion(
                            id: key,
                            question: page['question'],
                            type: page['type'],
                            scaleMin: page['scaleMin'],
                            scaleMax: page['scaleMax'],
                          ),
                          answer: answers[key],
                          onChanged: (val) {
                            setState(() {
                              answers[key] = val;
                            });
                          },
                          answers: answers,
                        );
                      } else if (page['type'] == QuestionType.text) {
                        questionWidget = AdvancedQuestionWidget(
                          question: AdvancedQuestion(
                            id: key,
                            question: page['question'],
                            type: page['type'],
                          ),
                          answer: answers[key],
                          onChanged: (val) {
                            setState(() {
                              answers[key] = val;
                            });
                          },
                          answers: answers,
                        );
                      } else {
                        questionWidget = const SizedBox.shrink();
                      }
                    } else {
                      questionWidget = const SizedBox.shrink();
                    }
                    return SingleChildScrollView(
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
                      onPressed: () {
                        final missing = _missingQuestions();
                        if (missing.isEmpty) {
                          _submit();
                        } else {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Faltan respostas'),
                                  content: Text(
                                    'Por favor, responda todas as perguntas antes de finalizar.\n\nFaltam:\n${missing.join('\n')}',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                          );
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
            // Mostrar campo 'Outro' solo si está seleccionada la opción 'Outro'
            if (q.allowOther && _localAnswer == q.options.length - 1)
              ListTile(
                title: const Text('Outro (especificar)'),
                subtitle: TextField(
                  onChanged: (val) {
                    widget.onChanged({'outro': val});
                    // Guardar el texto en answers['qXX_Outro']
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
            // Mostrar campo 'Outro' solo si está seleccionada la opción 'Outro'
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
