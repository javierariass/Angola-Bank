import 'package:flutter/material.dart';
import '../data/advanced_questions.dart';
import '../services/firebase_service.dart';

class QuestionnairePage extends StatefulWidget {
	const QuestionnairePage({super.key});

	@override
	State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
	final Map<String, dynamic> answers = {};
	DateTime? _startTime;
	DateTime? _endTime;
	Duration? _totalTime;

	@override
	void initState() {
		super.initState();
		_startTime = DateTime.now();
	}

	Map<String, dynamic> _formatAnswersForRow() {
		final Map<String, dynamic> row = {};
		for (final q in advancedQuestions) {
			final val = answers[q.id];
			if (q.type == QuestionType.multipleChoice) {
				for (int i = 0; i < q.options.length; i++) {
					row['${q.id}_${q.options[i]}'] = (val is List && val.contains(i));
				}
				if (q.allowOther && val is String && val.isNotEmpty) {
					row['${q.id}_Outro'] = val;
				}
			} else if (q.type == QuestionType.singleChoice) {
				if (val is int && val >= 0 && val < q.options.length) {
					row[q.id] = q.options[val];
				} else if (q.allowOther && val is String && val.isNotEmpty) {
					row[q.id] = val;
				} else {
					row[q.id] = val;
				}
			} else {
				row[q.id] = val;
			}
		}
		row['startTime'] = _startTime?.toIso8601String();
		row['endTime'] = _endTime?.toIso8601String();
		row['totalTimeSeconds'] = _totalTime?.inSeconds;
		return row;
	}

	void _submit() async {
		_endTime = DateTime.now();
		_totalTime = _endTime!.difference(_startTime!);
		final row = _formatAnswersForRow();
		bool uploaded = true;
		try {
			await uploadQuizResult(
				answers: row,
				startTime: _startTime!,
				endTime: _endTime!,
				totalTime: _totalTime!,
			).timeout(const Duration(seconds: 2));
		} catch (_) {
			uploaded = false;
		}
		if (!mounted) return;
		showDialog(
			context: context,
			builder: (_) => AlertDialog(
				title: const Text('Questionário finalizado!'),
				content: Text(
					'Obrigado por completar o questionário.\n'
					'Tempo total: ${_totalTime!.inMinutes} min ${_totalTime!.inSeconds % 60} seg\n'
					'Sincronização: ${uploaded ? "OK" : "Pendente"}'
				),
				actions: [
					TextButton(
						onPressed: () {
							Navigator.of(context).popUntil((route) => route.isFirst);
						},
						child: const Text('Voltar ao início'),
					)
				],
			),
		);
	}

	bool _allAnswered() {
		for (final q in advancedQuestions) {
			final val = answers[q.id];
			if (q.type == QuestionType.text) {
				if (val == null || val.toString().isEmpty) return false;
			} else if (q.type == QuestionType.multipleChoice) {
				if (val == null || (val is List && val.isEmpty)) return false;
			} else {
				if (val == null) return false;
			}
		}
		return true;
	}

       int _currentPage = 0;
       final PageController _pageController = PageController();

       @override
       Widget build(BuildContext context) {
	       // Opciones dinámicas para Q03
	       List<String> bancosQ2 = [];
	       final q2 = advancedQuestions.firstWhere((q) => q.id == 'q02', orElse: () => AdvancedQuestion(id: '', question: '', type: QuestionType.singleChoice));
	       if (answers['q02'] != null && answers['q02'] is List) {
		       final indices = answers['q02'] as List;
		       bancosQ2 = [for (var i in indices) if (i is int && i >= 0 && i < q2.options.length) q2.options[i]];
		       if (!bancosQ2.contains('Outro')) bancosQ2.add('Outro');
	       }

	       return Scaffold(
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
							       itemCount: advancedQuestions.length,
							       onPageChanged: (i) {
								       setState(() { _currentPage = i; });
							       },
							       itemBuilder: (context, index) {
								       final q = advancedQuestions[index];
								       Widget questionWidget;
								       if (q.id == 'q03') {
									       questionWidget = AdvancedQuestionWidget(
										       question: AdvancedQuestion(
											       id: q.id,
											       question: q.question,
											       type: q.type,
											       options: bancosQ2,
											       allowOther: true,
										       ),
										       answer: answers[q.id],
										       onChanged: (val) {
											       setState(() {
												       answers[q.id] = val;
											       });
										       },
									       );
								       } else {
									       questionWidget = AdvancedQuestionWidget(
										       question: q,
										       answer: answers[q.id],
										       onChanged: (val) {
											       setState(() {
												       answers[q.id] = val;
											       });
										       },
									       );
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
														       'Pregunta ${index + 1} de ${advancedQuestions.length}',
														       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
										       _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
									       },
									       icon: const Icon(Icons.arrow_back),
									       label: const Text('Anterior'),
								       ),
							       if (_currentPage < advancedQuestions.length - 1)
								       ElevatedButton.icon(
									       onPressed: () {
										       _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
									       },
									       icon: const Icon(Icons.arrow_forward),
									       label: const Text('Siguiente'),
								       ),
							       if (_currentPage == advancedQuestions.length - 1)
								       ElevatedButton(
									       onPressed: _allAnswered() ? _submit : null,
									       child: const Text('Finalizar'),
								       ),
						       ],
					       ),
					       const SizedBox(height: 8),
					       LinearProgressIndicator(
						       value: (_currentPage + 1) / advancedQuestions.length,
						       minHeight: 6,
					       ),
				       ],
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
	const AdvancedQuestionWidget({
		required this.question,
		required this.answer,
		required this.onChanged,
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
										setState(() { _localAnswer = val; });
										widget.onChanged(val);
									},
								);
							}),
						if (q.options.isEmpty || q.allowOther)
							ListTile(
								title: Text(q.options.isEmpty ? 'Escreva o seu banco principal' : 'Outro (especificar)'),
								subtitle: TextField(
									onChanged: (val) {
										setState(() { _localAnswer = val; });
										widget.onChanged(val);
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
						if (q.allowOther)
							ListTile(
								title: const Text('Outro (especificar)'),
								subtitle: TextField(
									onChanged: (val) {
										setState(() { _localAnswer = val; });
										widget.onChanged(val);
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
								setState(() { _localAnswer = val.round(); });
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
								setState(() { _localAnswer = val; });
								widget.onChanged(val);
							},
						),
					],
				);
		}
	}
}
