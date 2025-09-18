import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> uploadQuizResult({
  required Map<String, dynamic> answers,
  required DateTime startTime,
  required DateTime endTime,
  required Duration totalTime,
}) async {
  try {
    await FirebaseFirestore.instance.collection('quiz_results').add({
      'answers': answers,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalTimeSeconds': totalTime.inSeconds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    // Si falla, guarda localmente
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_results') ?? [];
    pending.add(jsonEncode({
      'answers': answers,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalTimeSeconds': totalTime.inSeconds,
    }));
    await prefs.setStringList('pending_results', pending);
  }
}

Future<bool> tryUploadPendingResults() async {
  final prefs = await SharedPreferences.getInstance();
  final pending = prefs.getStringList('pending_results') ?? [];
  if (pending.isEmpty) return true;
  final List<String> stillPending = [];
  bool allUploaded = true;
  for (final item in pending) {
    final data = jsonDecode(item);
    try {
      await FirebaseFirestore.instance.collection('quiz_results').add({
        'answers': data['answers'],
        'startTime': data['startTime'],
        'endTime': data['endTime'],
        'totalTimeSeconds': data['totalTimeSeconds'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      stillPending.add(item);
      allUploaded = false;
    }
  }
  await prefs.setStringList('pending_results', stillPending);
  return allUploaded;
}