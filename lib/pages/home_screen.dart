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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;

  late Animation<Offset> _titleOffset;
  late Animation<Offset> _buttonOffset;
  late Animation<double> _titleOpacity;
  late Animation<double> _buttonOpacity;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Animación del título
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleOffset = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));
    _titleOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeIn));

    // Animación del botón
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonOffset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
    _buttonOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

    // Animación del logo central (zoom/parallax suave)
    //_logoController = AnimationController(
    // vsync: this,
    //  duration: const Duration(seconds: 6),
    //)..repeat(reverse: true);
    //_logoScale = Tween<double>(begin: 1.0, end: 1.05).animate(
    // CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    //);

    // Iniciar animaciones
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth =
        (MediaQuery.of(context).size.width * devicePixelRatio).round();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Image.asset("assets/fondo.png", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),

          SafeArea(
            child: Column(
              children: [
                // Texto superior animado
                SlideTransition(
                  position: _titleOffset,
                  child: FadeTransition(
                    opacity: _titleOpacity,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Bem-vindo ao Assertys",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Botón inferior animado
                SlideTransition(
                  position: _buttonOffset,
                  child: FadeTransition(
                    opacity: _buttonOpacity,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.7,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                              shadowColor: Colors.black45,
                            ),
                            onPressed:
                                _loading
                                    ? null
                                    : () async {
                                      setState(() => _loading = true);

                                      try {
                                        await syncLocalUsersWithFirestore();
                                        widget.onNext?.call();
                                      } catch (e, st) {
                                        debugPrint(
                                          "Error en sincronización: $e\n$st",
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Error ao sincronizar os dados.",
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => _loading = false);
                                        }
                                      }
                                    },
                            child:
                                _loading
                                    ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                    : const Text(
                                      "Próximo",
                                      style: TextStyle(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
