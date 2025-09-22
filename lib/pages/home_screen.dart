import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/fondo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 🔹 Texto movido hacia arriba con padding
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "Welcome to Assertys",
                style: const TextStyle(
                  fontFamily: 'Roboto', //  aquí defines la fuente
                  color: Color.fromARGB(255, 237, 239, 237),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 🔹 Centrar el botón en el resto de la pantalla
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.end, // empuja el botón hacia abajo
                crossAxisAlignment:
                    CrossAxisAlignment.center, // lo centra horizontalmente
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 233, 236, 233),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/app_home');
                    },
                    child: const Text("Next"),
                  ),
                  SizedBox(height: 20), // separación desde el borde inferior
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
