import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zapato_model.dart';

class ApiService {
  final String urlInventario =
      'https://js7854.app.n8n.cloud/webhook/929a678f-a3be-409b-b55a-e81a024ae428';
  final String urlRegistro =
      'https://js7854.app.n8n.cloud/webhook/registrar-usuario';
  final String urlLogin = 'https://js7854.app.n8n.cloud/webhook/validar-login';
  final String urlPedidos = 'https://js7854.app.n8n.cloud/webhook/crear-pedido';
  final String urlUpdatePerfil =
      'https://js7854.app.n8n.cloud/webhook/actualizar-perfil';
  final String urlVerificarOTP =
      'https://js7854.app.n8n.cloud/webhook/verificar-correo';

  // 🌟 NUEVO WEBHOOK: Para pedir el historial de compras a n8n
  final String urlHistorial =
      'https://js7854.app.n8n.cloud/webhook/obtener-historial';

  Future<List<Zapato>> obtenerZapatos() async {
    try {
      final response = await http.get(Uri.parse(urlInventario));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Zapato.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> solicitarCodigoOTP(String correo, String telefono) async {
    try {
      final response = await http.post(
        Uri.parse(urlVerificarOTP),
        body: {'correo': correo, 'telefono': telefono},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('🔥 LLEGÓ DE N8N: $data');

        if (data is List) {
          if (data.isNotEmpty) {
            data = data.first;
          } else {
            return 'ERROR';
          }
        }

        if (data['existe'] == true) {
          return 'DUPLICADO';
        }

        if (data['codigo'] != null) {
          String codigoLimpio = data['codigo'].toString().trim();
          print('🔥 CÓDIGO LISTO PARA COMPARAR: $codigoLimpio');
          return codigoLimpio;
        }
      }
      return 'ERROR';
    } catch (e) {
      print('🔥 ERROR TÉCNICO EN FLUTTER: $e');
      return 'ERROR';
    }
  }

  Future<bool> registrarEnN8N(
    String nombre,
    String correo,
    String password,
    String telefono,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(urlRegistro),
        body: {
          'nombre': nombre,
          'correo': correo,
          'password': password,
          'telefono': telefono,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loginEnN8N(String correo, String password) async {
    try {
      final response = await http.post(
        Uri.parse(urlLogin),
        body: {'correo': correo, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['login'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> crearPedido(
    String correoUsuario,
    String articulos,
    double total,
    String nuevoStockString,
    String idZapato,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(urlPedidos),
        body: {
          'correo': correoUsuario,
          'articulos': articulos,
          'total': total.toString(),
          'nuevoStock': nuevoStockString,
          'id': idZapato,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> actualizarPerfil(
    String correo,
    String nuevoNombre,
    String nuevaDireccion,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(urlUpdatePerfil),
        body: {
          'correo': correo,
          'nombre': nuevoNombre,
          'direccion': nuevaDireccion,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🌟 NUEVO MÉTODO: Trae la lista de pedidos de un usuario
  Future<List<dynamic>> obtenerHistorialPedidos(String correo) async {
    try {
      final response = await http.post(
        Uri.parse(urlHistorial),
        body: {'correo': correo},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('pedidos')) {
          return data['pedidos'];
        }
      }
      return [];
    } catch (e) {
      print('🔥 ERROR AL OBTENER HISTORIAL: $e');
      return [];
    }
  }
}
