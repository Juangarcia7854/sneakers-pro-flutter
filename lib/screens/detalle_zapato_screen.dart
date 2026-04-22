import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/zapato_model.dart';
import '../providers/wishlist_provider.dart';

class DetalleZapatoScreen extends StatefulWidget {
  final Zapato zapato;
  final Function(Zapato) onAgregarCarrito;

  const DetalleZapatoScreen({
    super.key,
    required this.zapato,
    required this.onAgregarCarrito,
  });

  @override
  _DetalleZapatoScreenState createState() => _DetalleZapatoScreenState();
}

class _DetalleZapatoScreenState extends State<DetalleZapatoScreen> {
  String _tallaSeleccionada = '';
  List<String> _tallasDisponibles = [];
  int _imagenSeleccionada = 0; // 🌟 CONTROLADOR DE LA GALERÍA

  @override
  void initState() {
    super.initState();
    _tallasDisponibles = widget.zapato.stockPorTalla.keys.toList();
    if (_tallasDisponibles.isNotEmpty) {
      _tallaSeleccionada = _tallasDisponibles.firstWhere(
        (t) => (widget.zapato.stockPorTalla[t] ?? 0) > 0,
        orElse: () => _tallasDisponibles.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final bool esFavorito = wishlistProvider.isFavorite(widget.zapato.modelo);
    final bool tieneStock = widget.zapato.tieneStockGeneral;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito
                      ? Colors.red
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
                onPressed: () =>
                    wishlistProvider.toggleFavorite(widget.zapato.modelo),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.zapato.id,
                child: Container(
                  color:
                      Colors.white, // 🌟 FONDO BLANCO FORZADO PARA MATAR BORDES
                  padding: const EdgeInsets.all(30),
                  child: CachedNetworkImage(
                    imageUrl: widget.zapato.imagenes.isNotEmpty
                        ? widget.zapato.imagenes[_imagenSeleccionada]
                        : widget.zapato.imagenUrl,
                    fit: BoxFit.contain, // 🌟 EVITA QUE SE ESTIRE
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.zapato.marca.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "\$${widget.zapato.precio.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.zapato.modelo,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),

                  // 🌟 NUEVA GALERÍA DINÁMICA DE MINIATURAS ESTILO ADIDAS
                  if (widget.zapato.imagenes.length > 1) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.zapato.imagenes.length,
                        itemBuilder: (context, index) {
                          final estaSeleccionada = _imagenSeleccionada == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _imagenSeleccionada = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              width: 70,
                              decoration: BoxDecoration(
                                color:
                                    Colors.white, // Fondo blanco en miniatura
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: estaSeleccionada
                                      ? (isDarkMode
                                            ? Colors.white
                                            : Colors.black)
                                      : Colors.grey.shade300,
                                  width: estaSeleccionada ? 2.5 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget.zapato.imagenes[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  Text(
                    "SELECCIONA TU TALLA",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildGridTallas(isDarkMode),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: tieneStock
                          ? () {
                              widget.zapato.tallaSeleccionada =
                                  _tallaSeleccionada;
                              widget.onAgregarCarrito(widget.zapato);
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.white
                            : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        tieneStock ? "AÑADIR AL CARRITO" : "AGOTADO",
                        style: TextStyle(
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTallas(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tallasDisponibles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final talla = _tallasDisponibles[index];
        final esSeleccionada = _tallaSeleccionada == talla;
        final stockTalla = widget.zapato.stockPorTalla[talla] ?? 0;
        final hayStockTalla = stockTalla > 0;

        return GestureDetector(
          onTap: hayStockTalla
              ? () => setState(() => _tallaSeleccionada = talla)
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: esSeleccionada
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: esSeleccionada
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : (isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
              ),
            ),
            child: Center(
              child: Text(
                talla,
                style: TextStyle(
                  fontWeight: esSeleccionada
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: esSeleccionada
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : (hayStockTalla
                            ? (isDarkMode ? Colors.white : Colors.black)
                            : Colors.grey),
                  decoration: hayStockTalla
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
