import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- AÑADE ESTE IMPORT

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Para validación
  bool _isLoading = false; // Para indicador de carga

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    // Verifica si el formulario es válido
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Muestra el indicador de carga
      });

      try {
        // ignore: unused_local_variable
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(), // Usa .trim() para quitar espacios
          password: _passwordController.text.trim(),
        );

        // Si el registro es exitoso, AuthWrapper se encargará de redirigir a HomeScreen.
        // Puedes mostrar un mensaje de éxito si lo deseas, aunque la redirección es la principal indicación.
        if (mounted) { // mounted se usa para verificar si el widget todavía está en el árbol de widgets
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Registro exitoso!')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
          // No es necesario Navigator.pop() aquí si AuthWrapper funciona,
          // ya que el cambio de estado de auth debería llevar a HomeScreen.
        }
      } on FirebaseAuthException catch (e) {
        // Manejo de errores específicos de Firebase Auth
        String message;
        if (e.code == 'weak-password') {
          message = 'La contraseña proporcionada es demasiado débil.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Ya existe una cuenta para ese correo electrónico.';
        } else if (e.code == 'invalid-email') {
          message = 'El correo electrónico no es válido.';
        } else {
          message = 'Ocurrió un error de registro: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Manejo de otros errores
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ocurrió un error inesperado: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        // Se ejecuta siempre, haya o no error
        if (mounted) {
          setState(() {
            _isLoading = false; // Oculta el indicador de carga
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // Envuelve tu Column con un Form
          key: _formKey, // Asigna la GlobalKey al Form
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField( // Cambiado a TextFormField
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) { // Validador para el correo
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, ingresa un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField( // Cambiado a TextFormField
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) { // Validador para la contraseña
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading) // Muestra CircularProgressIndicator si _isLoading es true
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser, // Llama a _registerUser y deshabilita si está cargando
                  child: const Text('Registrarse'),
                ),
              TextButton(
                onPressed: _isLoading ? null : () { // Deshabilita si está cargando
                  Navigator.pop(context); // Volver a la pantalla anterior (LoginScreen)
                },
                child: const Text('¿Ya tienes cuenta? Inicia Sesión'),
              )
            ],
          ),
        ),
      ),
    );
  }
}