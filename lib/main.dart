import 'package:flutter/material.dart';
// Importa Firebase Core
import 'package:firebase_core/firebase_core.dart';
// Importa las opciones generadas por FlutterFire CLI
import 'firebase_options.dart'; // Asegúrate de que este archivo existe en tu carpeta lib/

void main() async { // <--- Cambiado a async
  // Asegúrate de que los bindings de Flutter estén inicializados ANTES de Firebase.initializeApp
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp( // <--- Añadido await
    options: DefaultFirebaseOptions.currentPlatform, // Usa las opciones específicas de la plataforma actual
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Puedes cambiar el title si quieres, por ejemplo a 'MasterTask Mobile'
      title: 'MasterTask Mobile Firebase', // <--- Cambiado para reflejar el proyecto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Puedes quitar useMaterial3: true si no lo necesitas o si causa problemas con tu diseño.
        // useMaterial3: true, // Comentado por si acaso, descomenta si lo usas.
      ),
      // Dejamos MyHomePage por ahora, pero puedes cambiarlo por tu pantalla principal real
      home: const MyHomePage(title: 'Firebase Inicializado!'), // <--- Cambiado el título para verificar
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title), // Mostrará "Firebase Inicializado!"
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Firebase debería estar funcionando.'), // <--- Mensaje cambiado
            const Text('Has presionado el botón estas veces:'), // Manteniendo el contador
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}