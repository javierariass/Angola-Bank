// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNext;
  const HomeScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 59, 12),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondo.png"),
            fit: BoxFit.scaleDown,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Text(
                "Bem-vindo ao Assertys",
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color.fromARGB(255, 251, 252, 251),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 245, 247, 245),
                    ),
                    onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );
                        try {
                          await syncLocalUsersWithFirestore();
                        } catch (_) {}
                        Navigator.of(context).pop();
                        if (onNext != null) onNext!();
                      },
                    child: const Text("Próximo"),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
