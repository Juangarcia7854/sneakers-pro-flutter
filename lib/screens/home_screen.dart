import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// Importaciones de tu ecosistema
import '../services/api_service.dart';
import '../models/zapato_model.dart';
import '../providers/wishlist_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'detalle_zapato_screen.dart';
import '../pages/wishlist_page.dart';
import 'vistas_extras.dart';
import 'login_screen.dart'; // 🌟 IMPORTAMOS EL LOGIN PARA PODER VOLVER A ÉL

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  final _formatoMoneda = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$ ',
    decimalDigits: 0,
  );

  // --- ESTADO DE DATOS ---
  List<Zapato> _todosLosZapatos = [];
  List<Zapato> _zapatosFiltrados = [];
  String _categoriaSeleccionada = 'Todos';
  String _terminoBusqueda = '';
  bool _isLoading = true;
  Timer? _debouncer;

  // --- NAVEGACIÓN Y CARRITO ---
  int _indiceSeleccionado = 0;
  final List<Zapato> _carrito = [];
  final List<String> _categorias = [
    'Todos',
    'Nike',
    'Adidas',
    'Jordan',
    'Puma',
    'Louis Vuitton',
  ];

  @override
  void initState() {
    super.initState();
    _cargarZapatos();
  }

  Future<void> _cargarZapatos() async {
    setState(() => _isLoading = true);
    final zapatos = await _apiService.obtenerZapatos();
    setState(() {
      _todosLosZapatos = zapatos;
      _zapatosFiltrados = zapatos;
      _isLoading = false;
    });
  }

  void _filtrarZapatos() {
    setState(() {
      _zapatosFiltrados = _todosLosZapatos.where((z) {
        final coincideCat =
            _categoriaSeleccionada == 'Todos' ||
            z.marca.toLowerCase() == _categoriaSeleccionada.toLowerCase();

        final coincideBusqueda = z.modelo.toLowerCase().contains(
          _terminoBusqueda.toLowerCase(),
        );
        return coincideCat && coincideBusqueda;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _terminoBusqueda = query);
      _filtrarZapatos();
    });
  }

  void _agregarAlCarrito(Zapato z) {
    setState(() => _carrito.add(z));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${z.modelo} agregado al carrito'),
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: _indiceSeleccionado == 0
          ? _buildAppBar(isDarkMode, userProvider)
          : null,
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: [
          _buildPrincipal(isDarkMode),
          _buildCarrito(isDarkMode, userProvider),
          _buildPerfil(isDarkMode, userProvider),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: (index) => setState(() => _indiceSeleccionado = index),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: isDarkMode ? Colors.white : Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text(_carrito.length.toString()),
              isLabelVisible: _carrito.isNotEmpty,
              child: const Icon(Icons.shopping_bag),
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, UserProvider userProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hola,",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            userProvider.nombre,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        IconButton(
          icon: Icon(
            Icons.favorite_border,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WishlistPage()),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificacionesScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipal(bool isDarkMode) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarZapatos,
      color: isDarkMode ? Colors.white : Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildSearchBar(isDarkMode),
              const SizedBox(height: 25),
              Text(
                "Categorías",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              _buildCategorias(isDarkMode),
              const SizedBox(height: 25),
              _buildCatalogo(isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      onChanged: _onSearchChanged,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: "Buscar tus sneakers...",
        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white54 : Colors.grey,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategorias(bool isDarkMode) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          final estaSeleccionada = _categoriaSeleccionada == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: estaSeleccionada,
              onSelected: (val) {
                setState(() => _categoriaSeleccionada = cat);
                _filtrarZapatos();
              },
              selectedColor: isDarkMode ? Colors.white : Colors.black,
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.grey[100],
              labelStyle: TextStyle(
                color: estaSeleccionada
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : (isDarkMode ? Colors.white70 : Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogo(bool isDarkMode) {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _zapatosFiltrados.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        childAspectRatio: 0.55,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final zapato = _zapatosFiltrados[index];
        return _buildTarjetaZapato(zapato, isDarkMode);
      },
    );
  }

  Widget _buildTarjetaZapato(Zapato zapato, bool isDarkMode) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isFavorite = wishlistProvider.isFavorite(zapato.modelo);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => DetalleZapatoScreen(
            zapato: zapato,
            onAgregarCarrito: _agregarAlCarrito,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Hero(
                          tag: zapato.id,
                          child: CachedNetworkImage(
                            imageUrl: zapato.imagenUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () =>
                          wishlistProvider.toggleFavorite(zapato.modelo),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: isDarkMode
                            ? Colors.black54
                            : Colors.white.withOpacity(0.8),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : (isDarkMode ? Colors.white : Colors.grey),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zapato.marca,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zapato.modelo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatoMoneda.format(zapato.precio),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
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

  Widget _buildCarrito(bool isDarkMode, UserProvider userProvider) {
    if (_carrito.isEmpty) {
      return Center(
        child: Text(
          "Tu carrito está vacío",
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
        ),
      );
    }
    double total = _carrito.fold(0, (sum, item) => sum + item.precio);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Tu Carrito",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _carrito.length,
            itemBuilder: (context, index) {
              final item = _carrito[index];
              return ListTile(
                leading: Image.network(item.imagenUrl, width: 50),
                title: Text(
                  item.modelo,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  "Talla: ${item.tallaSeleccionada}  |  ${_formatoMoneda.format(item.precio)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _carrito.removeAt(index)),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black54 : Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _formatoMoneda.format(total),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () async {
                    final zapato = _carrito.first;
                    String tallaComprada = zapato.tallaSeleccionada;

                    if (tallaComprada.isEmpty) {
                      tallaComprada = zapato.stockPorTalla.entries
                          .firstWhere(
                            (e) => e.value > 0,
                            orElse: () => const MapEntry("", 0),
                          )
                          .key;
                    }

                    Map<String, int> stockTemporal = Map.from(
                      zapato.stockPorTalla,
                    );

                    if (tallaComprada.isNotEmpty &&
                        stockTemporal.containsKey(tallaComprada)) {
                      stockTemporal[tallaComprada] =
                          stockTemporal[tallaComprada]! - 1;
                    }

                    String nuevoStockString = stockTemporal.entries
                        .map((e) => "${e.key}:${e.value}")
                        .join(", ");

                    String articulos = _carrito.map((z) => z.modelo).join(", ");

                    bool ok = await _apiService.crearPedido(
                      userProvider.correo,
                      articulos,
                      total,
                      nuevoStockString,
                      zapato.id.toString(),
                    );

                    if (ok) {
                      setState(() => _carrito.clear());
                      await _cargarZapatos();
                      _mostrarExito();
                    }
                  },
                  child: Text(
                    "CONFIRMAR PEDIDO",
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarExito() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Gracias por tu compra!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildPerfil(bool isDarkMode, UserProvider userProvider) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDarkMode ? Colors.white : Colors.black,
            child: Icon(
              Icons.person,
              size: 50,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          userProvider.nombre,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          userProvider.correo,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditarPerfilScreen(),
              ),
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text("EDITAR PERFIL"),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
              side: BorderSide(
                color: isDarkMode ? Colors.white24 : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
        ListTile(
          leading: Icon(
            Icons.history,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          title: Text(
            "Historial de Pedidos",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistorialScreen()),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          title: Text(
            "Dirección de Envío",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Tu dirección principal es: ${userProvider.direccion}",
              ),
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.payment,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          title: Text(
            "Métodos de Pago",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MetodosPagoScreen()),
          ),
        ),

        // 🌟 AQUÍ ESTÁ EL NUEVO BOTÓN DE CERRAR SESIÓN
        const SizedBox(height: 20),
        Divider(color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            "Cerrar Sesión",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () async {
            // 1. Borramos la memoria (disco duro)
            await userProvider.cerrarSesion();

            // 2. Lo mandamos al Login y borramos el historial de ventanas
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
