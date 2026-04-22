import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  // Lista donde guardaremos los nombres o modelos de los zapatos favoritos
  final List<String> _favorites = [];

  List<String> get favorites => _favorites;

  // Función para agregar o quitar de la lista de deseos
  void toggleFavorite(String modeloZapato) {
    if (_favorites.contains(modeloZapato)) {
      _favorites.remove(modeloZapato); // Si ya estaba, lo quita
    } else {
      _favorites.add(modeloZapato); // Si no estaba, lo agrega
    }
    notifyListeners(); // Le avisa a la pantalla que cambie el color del corazón
  }

  // Función para saber si un zapato está en la lista o no
  bool isFavorite(String modeloZapato) {
    return _favorites.contains(modeloZapato);
  }
}
