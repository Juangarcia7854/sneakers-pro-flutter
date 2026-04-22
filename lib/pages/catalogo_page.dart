import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

// Importaciones de tus archivos
import '../models/zapato_model.dart';
import '../services/api_service.dart';
import '../providers/wishlist_provider.dart';
import '../screens/detalle_zapato_screen.dart';
import 'wishlist_page.dart'; // Asegúrate de tener este archivo creado

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final ApiService _apiService = ApiService();
  String _searchQuery = ''; // Aquí guardamos lo que el usuario escribe

  @override
  Widget build(BuildContext context) {
    // 🌙 Detección de Modo Oscuro
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          "SNEAKERS PRO",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          // 💖 Botón para ir a la Lista de Deseos
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishlistPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 BARRA DE BÚSQUEDA
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Buscar marca o modelo...",
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.white54 : Colors.grey,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF1E1E1E)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 📦 CATÁLOGO DE ZAPATOS (Desde n8n)
          Expanded(
            child: FutureBuilder<List<Zapato>>(
              future: _apiService.obtenerZapatos(),
              builder: (context, snapshot) {
                // Estado de Carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.grey),
                  );
                }

                // Manejo de Errores
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error de conexión con ifcodedv Cloud",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  );
                }

                // Sin Datos
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No hay zapatos en el inventario."),
                  );
                }

                // Filtrar datos según la búsqueda
                final zapatos = snapshot.data!;
                final zapatosFiltrados = zapatos.where((zapato) {
                  return zapato.modelo.toLowerCase().contains(_searchQuery) ||
                      zapato.marca.toLowerCase().contains(_searchQuery);
                }).toList();

                if (zapatosFiltrados.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron resultados."),
                  );
                }

                // 🖼️ GRID DE PRODUCTOS
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos columnas
                    childAspectRatio: 0.65, // Proporción de la tarjeta
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: zapatosFiltrados.length,
                  itemBuilder: (context, index) {
                    final zapato = zapatosFiltrados[index];
                    return _buildZapatoCard(zapato, isDarkMode);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🃏 WIDGET: Tarjeta individual del zapato
  Widget _buildZapatoCard(Zapato zapato, bool isDarkMode) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isFavorite = wishlistProvider.isFavorite(zapato.modelo);

    return GestureDetector(
      onTap: () {
        // Navegar al detalle del zapato
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleZapatoScreen(
              zapato: zapato,
              // Función temporal de carrito para que no de error
              onAgregarCarrito: (z) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('¡${z.modelo} agregado al carrito!'),
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                );
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black26
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen y Botón de Favorito
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF6F6F6),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Hero(
                        tag: zapato.id,
                        child: CachedNetworkImage(
                          imageUrl: zapato.imagenUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  // Botón Corazón
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          wishlistProvider.toggleFavorite(zapato.modelo),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: isDarkMode
                            ? Colors.black54
                            : Colors.white,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : (isDarkMode ? Colors.white : Colors.grey),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Textos (Marca, Modelo, Precio)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zapato.marca.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zapato.modelo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${zapato.precio.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
