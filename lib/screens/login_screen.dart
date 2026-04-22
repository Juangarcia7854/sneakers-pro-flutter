import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  void _iniciarSesion() async {
    setState(() => _isLoading = true);

    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    // Conexión con n8n
    bool exito = await apiService.loginEnN8N(correo, password);

    setState(() => _isLoading = false);

    if (exito) {
      String nombreTemporal = correo.split('@')[0];
      if (nombreTemporal.isNotEmpty) {
        nombreTemporal =
            nombreTemporal[0].toUpperCase() + nombreTemporal.substring(1);
      } else {
        nombreTemporal = "Usuario";
      }

      // 🌟 GUARDAMOS EN EL DISCO DURO (Memoria Persistente)
      await Provider.of<UserProvider>(context, listen: false).setUsuario(
        nombreTemporal,
        correo,
        "Sin dirección registrada", // Dirección por defecto
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correo o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Colors.black,
                        size: 70,
                      ),
                      const Text(
                        "SNEAKERS PRO",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(height: 3, width: 40, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              "Bienvenido de nuevo",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Ingresa tus credenciales para continuar",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildInput(
              label: 'Correo Electrónico',
              icon: Icons.email_outlined,
              controller: _correoController,
            ),
            const SizedBox(height: 20),
            _buildInput(
              label: 'Contraseña',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPass: true,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'INGRESAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const RegisterScreen()),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      TextSpan(text: "¿No tienes cuenta? "),
                      TextSpan(
                        text: "Regístrate aquí",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPass = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}
