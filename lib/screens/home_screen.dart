// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Asegúrate de tener este paquete añadido si lo usas
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Función para cerrar sesión
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!kIsWeb) {
        final googleSignIn = GoogleSignIn();
        // Es bueno verificar si realmente hay una sesión de Google activa antes de intentar cerrarla.
        // Sin embargo, `isSignedIn()` puede no ser 100% fiable en todos los escenarios si la app se cerró.
        // A veces, simplemente llamar a signOut() es suficiente si el usuario usó Google.
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
          print("Cerrada sesión de GoogleSignIn");
        }
      }
      print("Cierre de sesión de Firebase exitoso.");

      // Navegar a LoginScreen y remover todas las rutas anteriores
      // Usamos 'mounted' para asegurarnos de que el widget todavía está en el árbol
      // antes de intentar usar su 'context'.
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      }

    } catch (e) {
      print('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario actual para mostrar su información
    // Es seguro llamar a FirebaseAuth.instance.currentUser aquí porque AuthWrapper
    // ya se aseguró de que haya un usuario si esta pantalla se está mostrando.
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MasterTask - Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            // Llama al método _signOut de esta clase de estado
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (user != null) ...[ // Si hay un usuario, muestra su información
                if (user.photoURL != null)
                  Padding( // Añadido Padding para la foto
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                      radius: 40,
                    ),
                  ),
                Text('Usuario: ${user.displayName ?? user.email ?? "Anónimo"}', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Email: ${user.email ?? "No disponible"}', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('UID: ${user.uid}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
              ] else ...[
                // Este caso no debería ocurrir si AuthWrapper funciona bien,
                // pero es bueno tener un fallback.
                const Text("No se pudo cargar la información del usuario o no hay sesión activa."),
              ]
            ],
          ),
        ),
      ),
    );
  }
}