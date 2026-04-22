import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _nombre = '';
  String _correo = '';
  String _direccion = '';
  String _telefono = '';
  bool _isLoggedIn = false;

  String get nombre => _nombre;
  String get correo => _correo;
  String get direccion => _direccion;
  String get telefono => _telefono;
  bool get isLoggedIn => _isLoggedIn;

  // 🌟 1. MÉTODO PARA CARGAR LA MEMORIA (Se ejecuta al abrir la app)
  Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      _nombre = prefs.getString('nombre') ?? 'Invitado';
      _correo = prefs.getString('correo') ?? '';
      _direccion = prefs.getString('direccion') ?? 'Sin dirección registrada';
      _telefono = prefs.getString('telefono') ?? '';
    }
    notifyListeners();
  }

  // 🌟 2. MÉTODO PARA GUARDAR LA MEMORIA (Se ejecuta al hacer Login o Registro)
  Future<void> setUsuario(
    String nombre,
    String correo,
    String direccion, {
    String telefono = "",
  }) async {
    _nombre = nombre;
    _correo = correo;
    _direccion = direccion;
    _telefono = telefono;
    _isLoggedIn = true;

    // Guardamos en el disco duro del teléfono
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('nombre', nombre);
    await prefs.setString('correo', correo);
    await prefs.setString('direccion', direccion);
    await prefs.setString('telefono', telefono);

    notifyListeners();
  }

  // 🌟 3. ACTUALIZAR PERFIL EN MEMORIA
  Future<void> actualizarPerfil(String nombre, String direccion) async {
    _nombre = nombre;
    _direccion = direccion;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', nombre);
    await prefs.setString('direccion', direccion);

    notifyListeners();
  }

  // 🌟 4. CERRAR SESIÓN (Borra la memoria para que entre otro cliente)
  Future<void> cerrarSesion() async {
    _nombre = '';
    _correo = '';
    _direccion = '';
    _telefono = '';
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia la caja fuerte por completo

    notifyListeners();
  }
}
