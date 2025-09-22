
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Crea un nuevo documento de sesión y guarda su ID localmente
Future<String?> createSessionDoc(String user) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final doc = await FirebaseFirestore.instance.collection('session_starts').add({
      'user': user,
      'quizCount': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await prefs.setString('current_session_doc_id', doc.id);
    return doc.id;
  } catch (_) {
    // Si falla, crea un registro local
    final localDoc = jsonEncode({'user': user, 'quizCount': 0, 'timestamp': DateTime.now().toIso8601String()});
    await prefs.setString('local_current_session_doc', localDoc);
    await prefs.remove('current_session_doc_id');
    return null;
  }
}

// Actualiza el contador en el documento de sesión actual (Firestore/local)
Future<void> updateCurrentSessionQuizCount(String user, int count) async {
  final prefs = await SharedPreferences.getInstance();
  String? docId = prefs.getString('current_session_doc_id');
  if (docId != null) {
    try {
      await FirebaseFirestore.instance.collection('session_starts').doc(docId).update({
        'quizCount': count,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Si falla, actualiza local
      final localDoc = jsonEncode({'user': user, 'quizCount': count, 'timestamp': DateTime.now().toIso8601String()});
      await prefs.setString('local_current_session_doc', localDoc);
    }
  } else {
    // Solo local
    final localDoc = jsonEncode({'user': user, 'quizCount': count, 'timestamp': DateTime.now().toIso8601String()});
    await prefs.setString('local_current_session_doc', localDoc);
  }
}

// Sincroniza el registro local de la sesión actual con Firestore si fue actualizado offline
Future<void> trySyncLocalCurrentSessionDoc(String user) async {
  final prefs = await SharedPreferences.getInstance();
  String? docId = prefs.getString('current_session_doc_id');
  final localDocStr = prefs.getString('local_current_session_doc');
  if (docId != null && localDocStr != null) {
    final localDoc = jsonDecode(localDocStr);
    try {
      await FirebaseFirestore.instance.collection('session_starts').doc(docId).update({
        'quizCount': localDoc['quizCount'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      await prefs.remove('local_current_session_doc');
    } catch (_) {}
  }
}


// Intenta subir los conteos de cuestionarios guardados localmente
Future<void> tryUploadPendingSessionCounts() async {
  final prefs = await SharedPreferences.getInstance();
  final pending = prefs.getStringList('pending_session_counts') ?? [];
  if (pending.isEmpty) return;
  final List<String> stillPending = [];
  for (final item in pending) {
    final data = jsonDecode(item);
    try {
      await FirebaseFirestore.instance.collection('session_starts').add({
        'user': data['user'],
        'quizCount': data['quizCount'],
        'timestamp': data['timestamp'],
      });
    } catch (_) {
      stillPending.add(item);
    }
  }
  await prefs.setStringList('pending_session_counts', stillPending);
}

// Guarda el conteo de cuestionarios por sesión en Firestore
Future<void> saveSessionQuizCount(String user, int count) async {
  try {
    await FirebaseFirestore.instance.collection('session_starts').add({
      'user': user,
      'quizCount': count,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    // Si falla, guarda localmente
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_session_counts') ?? [];
    pending.add(jsonEncode({
      'user': user,
      'quizCount': count,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList('pending_session_counts', pending);
  }
}

Future<void> uploadQuizResult({
  required Map<String, dynamic> answers,
  required DateTime startTime,
  required DateTime endTime,
  required Duration totalTime,
}) async {
  try {
    await FirebaseFirestore.instance.collection('quiz_results').add({
      'answers': answers,
      'user': answers['user'],
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
      'user': answers['user'],
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