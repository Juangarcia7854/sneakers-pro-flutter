class Zapato {
  final int id;
  final String modelo;
  final String marca;
  final double precio;
  final String imagenUrl;
  final List<String> imagenes; // 🌟 NUEVO: Lista de múltiples fotos
  final Map<String, int> stockPorTalla;

  // 🌟 MEMORIA DE TALLA: Guarda la elección del usuario
  String tallaSeleccionada;

  Zapato({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.precio,
    required this.imagenUrl,
    required this.imagenes, // 🌟 REQUERIDO AHORA
    required this.stockPorTalla,
    this.tallaSeleccionada = '', // Por defecto vacía
  });

  factory Zapato.fromJson(Map<String, dynamic> json) {
    Map<String, int> mapaStock = {};

    if (json['tallas'] != null) {
      String tallasString = json['tallas'].toString();
      List<String> pares = tallasString.split(',');

      for (String par in pares) {
        List<String> datos = par.split(':');
        if (datos.length == 2) {
          String talla = datos[0].trim();
          int cantidad = int.tryParse(datos[1].trim()) ?? 0;
          mapaStock[talla] = cantidad;
        }
      }
    }

    // 🌟 MAGIA VISUAL: Separar los links por comas
    List<String> listaImagenes = [];
    String urlPrincipal = '';

    if (json['imagen_url'] != null) {
      String urlsRaw = json['imagen_url'].toString();
      listaImagenes = urlsRaw.split(',').map((e) => e.trim()).toList();
      urlPrincipal = listaImagenes.isNotEmpty ? listaImagenes.first : '';
    }

    return Zapato(
      id: json['id'] ?? 0,
      modelo: json['modelo'] ?? 'Modelo Desconocido',
      marca: json['marca'] ?? 'Marca',
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      imagenUrl: urlPrincipal, // Foto de portada
      imagenes: listaImagenes.isEmpty
          ? [urlPrincipal]
          : listaImagenes, // Todas las fotos
      stockPorTalla: mapaStock,
    );
  }

  bool get tieneStockGeneral => stockPorTalla.values.any((qty) => qty > 0);
}
