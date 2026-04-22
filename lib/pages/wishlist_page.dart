import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos el modo oscuro
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Escuchamos al cerebro de favoritos
    final wishlistProvider = context.watch<WishlistProvider>();
    final listaFavoritos = wishlistProvider.favorites;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "MI LISTA DE DESEOS",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: listaFavoritos.isEmpty
          ? _buildEstadoVacio(isDarkMode)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: listaFavoritos.length,
              itemBuilder: (context, index) {
                final nombreZapato = listaFavoritos[index];
                return _buildCardFavorito(
                  nombreZapato,
                  isDarkMode,
                  wishlistProvider,
                );
              },
            ),
    );
  }

  // Widget para cuando no hay nada guardado
  Widget _buildEstadoVacio(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "Aún no tienes favoritos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para cada zapato en la lista
  Widget _buildCardFavorito(
    String nombre,
    bool isDarkMode,
    WishlistProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              const SizedBox(width: 15),
              Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => provider.toggleFavorite(nombre),
          ),
        ],
      ),
    );
  }
}
