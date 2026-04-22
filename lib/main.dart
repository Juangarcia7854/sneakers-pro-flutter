import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

// 🌟 AJUSTA ESTA RUTA SI TU HOME SCREEN ESTÁ EN OTRA CARPETA (Ej: 'screens/home_screen.dart')
import 'screens/home_screen.dart';

import 'providers/wishlist_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  // 🌟 1. ASEGURAR QUE FLUTTER ESTÉ LISTO ANTES DE LEER LA MEMORIA DEL CELULAR
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sneakers Pro',

      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),

      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
      ),

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🌟 2. EL PORTERO AUTOMÁTICO (Revisa la caja fuerte antes de abrir)
      home: FutureBuilder(
        future: Provider.of<UserProvider>(
          context,
          listen: false,
        ).cargarSesion(),
        builder: (context, snapshot) {
          // Mientras lee el disco duro, mostramos carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            );
          }

          // Si encontró sesión, directo a comprar. Si no, a la pantalla de bienvenida.
          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoggedIn) {
                return const HomeScreen();
              } else {
                return const HomePage();
              }
            },
          );
        },
      ),
    );
  }
}
