// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Asegúrate de que este paquete esté añadido y obtenido
import 'package:flutter/foundation.dart' show kIsWeb;
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// VV AQUÍ EMPIEZA LA CLASE _LoginScreenState VV
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailPassword() async {
    // ... (tu código para inicio de sesión con email/password) ...
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        // ignore: unused_local_variable
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') { message = 'No se encontró un usuario para ese correo electrónico.';
        } else if (e.code == 'wrong-password') { message = 'Contraseña incorrecta proporcionada para ese usuario.';
        } else if (e.code == 'invalid-email') { message = 'El formato del correo electrónico no es válido.';
        } else if (e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') { message = 'Correo electrónico o contraseña incorrectos.';
        } else { message = 'Error de inicio de sesión: ${e.message}'; }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(message), backgroundColor: Colors.red),);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Ocurrió un error inesperado: $e'), backgroundColor: Colors.red),);
        }
      } finally {
        if (mounted) { setState(() { _isLoading = false; }); }
      }
    }
  }

  // VV AQUÍ DEBE ESTAR LA DEFINICIÓN DE _signInWithGoogle VV
  Future<void> _signInWithGoogle() async {
    print("Función _signInWithGoogle INVOCADA");
    setState(() {
      _isLoading = true;
      print("_signInWithGoogle: _isLoading = true");
    });

    try {
      UserCredential? userCredential;
      print("_signInWithGoogle: Intentando inicio de sesión con Google...");

      if (kIsWeb) {
        print("_signInWithGoogle: Plataforma WEB detectada.");
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        print("_signInWithGoogle: Llamando a signInWithPopup...");
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        print("_signInWithGoogle: signInWithPopup completado. User: ${userCredential.user?.displayName}");
      } else {
        print("_signInWithGoogle: Plataforma MÓVIL (Android/iOS) detectada.");
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        print("_signInWithGoogle: GoogleSignIn().signIn() completado. GoogleUser: ${googleUser?.displayName}");

        if (googleUser == null) {
          print("_signInWithGoogle: googleUser es null (flujo cancelado por el usuario).");
          // No es necesario setState aquí si no se cambió _isLoading a false todavía
          // El finally se encargará de _isLoading = false
          return; // Salir temprano si el usuario canceló
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print("_signInWithGoogle: Obtenida autenticación de Google. ID Token presente: ${googleAuth.idToken != null}");

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        print("_signInWithGoogle: Credencial OAuth creada. Llamando a signInWithCredential...");
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        print("_signInWithGoogle: signInWithCredential completado. User: ${userCredential.user?.displayName}");
      }

      // El if (mounted) aquí es importante porque signInWithCredential puede hacer que el widget se desmonte si navega
      if (userCredential != null && mounted) {
        print("_signInWithGoogle: Inicio de sesión con Google exitoso. Navegando a /home.");
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      } else if (userCredential == null && mounted) {
        // Si googleUser fue null y salimos temprano, este bloque no se ejecutará.
        // Este caso sería si signInWithPopup o signInWithCredential devolvieran null por alguna razón inesperada.
        print("_signInWithGoogle: userCredential es null o widget no montado después del login.");
      }

    } on FirebaseAuthException catch (e) {
      print("_signInWithGoogle: FirebaseAuthException: Código: ${e.code}, Mensaje: ${e.message}");
      String message = 'Error de inicio de sesión con Google: ${e.message}';
      if (e.code == 'account-exists-with-different-credential') {
        message = 'Ya existe una cuenta con este correo electrónico pero con un método de inicio de sesión diferente.';
      } else if (e.code == 'popup-closed-by-user' && kIsWeb) {
        message = 'Ventana de inicio de sesión cerrada por el usuario.';
      } else if (e.code == 'cancelled-popup-request' && kIsWeb) {
        message = 'Se canceló una solicitud de popup. Solo una puede estar activa a la vez.';
      } else if (e.code == 'popup-blocked' && kIsWeb) {
        message = 'La ventana emergente de Google fue bloqueada por el navegador. Revisa la configuración de pop-ups.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e, s) {
      print("_signInWithGoogle: Error inesperado: $e");
      print("_signInWithGoogle: Stack Trace: $s");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocurrió un error inesperado con Google Sign-In: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Asegúrate de que _isLoading se ponga en false solo si el widget sigue montado.
      if (mounted) {
        setState(() {
          _isLoading = false;
          print("_signInWithGoogle: _isLoading = false (en finally)");
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                // ... (resto de TextFormField para email)
                 decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, ingresa un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                // ... (resto de TextFormField para password)
                 decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu contraseña.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithEmailPassword,
                      child: const Text('Iniciar Sesión'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle, // <--- AQUÍ SE LLAMA
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [ // Añadido const
                           Text('Iniciar Sesión con Google', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
// VV AQUÍ TERMINA LA CLASE _LoginScreenState VV
}