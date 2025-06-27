import 'package:flutter/material.dart';
import 'services/internet_checked.dart';
import 'widgets/rating_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BlankPage(),
    );
  }
}

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});

  @override
  State<BlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initConnectivityListener((msg, connected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
          
          if (connected) {
            //Logica para subir base de datos          
          }
        }
      });
    });
  }

//Funcion para mostrar el rating bar
void _mostrarRatingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Califica esta app'),
      content: StarRating(
        initialRating: 4.0,
        onRatingChanged: (valor) {
          Navigator.pop(context); 
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        )
      ],
    ),
  );
}


  @override
  void dispose() {
    disposeConnectivityListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(), 
    );
  }
}
