// lib/main.dart

import 'package:flutter/material.dart';

// Imports de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Necesario para FirebaseAuth.instance
import 'firebase_options.dart'; // Generado por FlutterFire CLI

// Imports de tus pantallas (asegúrate de que la ruta sea correcta si usaste una subcarpeta "screens")
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Asegura la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MasterTask Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Puedes ajustar esto según tus preferencias de diseño
        
      ),
      debugShowCheckedModeBanner: false,
      // El AuthWrapper ahora decide qué pantalla mostrar inicialmente
      home: const AuthWrapper(),
      // Opcional: Definir rutas nombradas para una navegación más limpia si lo necesitas más adelante
      // Esto es útil si navegas desde lugares que no son directamente el AuthWrapper
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print("AuthWrapper: Construyendo..."); // Para ver cuándo se construye
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("AuthWrapper StreamBuilder: Estado de conexión: ${snapshot.connectionState}");
        if (snapshot.hasData) {
          print("AuthWrapper StreamBuilder: Usuario detectado (snapshot.hasData): ${snapshot.data!.uid}");
        } else {
          print("AuthWrapper StreamBuilder: No hay usuario (snapshot.hasData es false o snapshot.data es null)");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("AuthWrapper StreamBuilder: Mostrando CircularProgressIndicator");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          print("AuthWrapper StreamBuilder: Navegando a HomeScreen");
          return const HomeScreen();
        } else {
          print("AuthWrapper StreamBuilder: Navegando a LoginScreen");
          return const LoginScreen();
        }
      },
    );
  }
}