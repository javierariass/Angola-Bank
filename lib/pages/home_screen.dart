// ignore_for_file: use_build_, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNext;
  const HomeScreen({super.key, this.onNext});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ocultar status bar y navigation bar en modo inmersivo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth =
        (MediaQuery.of(context).size.width * devicePixelRatio).round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Texto superior con sombra aplicada a la tipografía (sin contenedor)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  "Bem-vindo ao Assertys",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color:
                          Color.fromARGB(255, 44, 15, 15), // mantengo el texto visible sobre el fondo oscuro
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Logo central libre
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset(
                      "assets/fondo.png",
                      fit: BoxFit.cover,
                      cacheWidth: targetWidth,
                      semanticLabel: "Logo de Assertys",
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Botón inferior con margen
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FractionallySizedBox(
                widthFactor: 0.7,
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 245, 247, 245),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black45,
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (_) => WillPopScope(
                              onWillPop: () async => false,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                      );
                      try {
                        await syncLocalUsersWithFirestore();
                      } catch (e, st) {
                        debugPrint("Error en sincronización: $e\n$st");
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error ao sincronizar os dados."),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) Navigator.of(context).pop();
                      }
                      widget.onNext?.call();
                    },
                    child: const Text(
                      "Próximo",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
