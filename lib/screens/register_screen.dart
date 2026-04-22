import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🌟 NUEVO
import '../providers/user_provider.dart'; // 🌟 NUEVO
import 'home_screen.dart'; // 🌟 NUEVO

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final ApiService apiService = ApiService();
  bool _isLoading = false;

  bool _esperandoCodigo = false;
  String _codigoSecretoDeN8N = "";

  void _solicitarVerificacion() async {
    if (_correoController.text.isEmpty || _telefonoController.text.isEmpty) {
      _mostrarSnack('Llena todos los campos', Colors.red);
      return;
    }
    setState(() => _isLoading = true);

    String respuesta = await apiService.solicitarCodigoOTP(
      _correoController.text.trim(),
      _telefonoController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (respuesta == 'DUPLICADO') {
      _mostrarSnack('Este correo ya está registrado', Colors.red);
    } else if (respuesta != 'ERROR') {
      setState(() {
        _codigoSecretoDeN8N = respuesta;
        _esperandoCodigo = true;
      });
      _mostrarSnack('Código enviado a tu teléfono', Colors.green);
    } else {
      _mostrarSnack('Error de conexión. Intenta de nuevo', Colors.red);
    }
  }

  void _verificarYRegistrar() async {
    if (_otpController.text.trim() == _codigoSecretoDeN8N) {
      setState(() => _isLoading = true);

      bool exito = await apiService.registrarEnN8N(
        _nombreController.text.trim(),
        _correoController.text.trim(),
        _passwordController.text.trim(),
        _telefonoController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (exito) {
        // 🌟 AUTO-LOGIN INMEDIATO EN EL DISCO DURO
        await Provider.of<UserProvider>(context, listen: false).setUsuario(
          _nombreController.text.trim(),
          _correoController.text.trim(),
          "Sin dirección registrada",
        );

        _mostrarSnack('¡Cuenta verificada y creada!', Colors.green);

        // 🌟 LO MANDAMOS DIRECTO A LA TIENDA Y BORRAMOS EL HISTORIAL DE PANTALLAS
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const HomeScreen()),
          (route) => false,
        );
      } else {
        _mostrarSnack('Error al guardar en base de datos.', Colors.red);
      }
    } else {
      _mostrarSnack('El código ingresado es incorrecto', Colors.red);
    }
  }

  void _mostrarSnack(String mensaje, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: _esperandoCodigo
            ? _buildPantallaOTP()
            : _buildPantallaRegistro(),
      ),
    );
  }

  Widget _buildPantallaRegistro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CREAR CUENTA',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 40),
        _buildField('Nombre completo', _nombreController, Icons.person),
        const SizedBox(height: 15),
        _buildField('Correo electrónico', _correoController, Icons.email),
        const SizedBox(height: 15),
        _buildField(
          'Teléfono (Celular)',
          _telefonoController,
          Icons.phone,
          tipoNumerico: true,
        ),
        const SizedBox(height: 15),
        _buildField(
          'Contraseña',
          _passwordController,
          Icons.lock,
          isPass: true,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _solicitarVerificacion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'ENVIAR CÓDIGO SMS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPantallaOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.verified_user_outlined, size: 80, color: Colors.green),
        const SizedBox(height: 20),
        const Text(
          'Verifica tu Teléfono',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          'Hemos enviado un código de 6 dígitos al número\n${_telefonoController.text}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 40),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 10,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: "000000",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verificarYRegistrar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'VERIFICAR Y CREAR CUENTA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _esperandoCodigo = false),
          child: const Text(
            "Cambiar datos",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPass = false,
    bool tipoNumerico = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      keyboardType: tipoNumerico ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
