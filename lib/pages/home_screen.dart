// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNext;
  const HomeScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    // Ocultar la barra superior (status bar)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    });
    return Scaffold(
  backgroundColor: Color.fromARGB(255, 30, 73, 27),
      body: Container(
        color: Color.fromARGB(255, 30, 73, 27),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Image.asset(
                      "assets/fondo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Center(
                child: Text(
                  "Bem-vindo ao Assertys",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color.fromARGB(255, 251, 252, 251),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 245, 247, 245),
                        textStyle: const TextStyle(fontSize: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
