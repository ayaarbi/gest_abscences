import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestAbsence',
      // --- CONFIGURATION DU THÈME ---
      debugShowCheckedModeBanner: false, // Enlever la bande debug

      
      // --- Thème Clair ---
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  ),
  // Force le texte à utiliser les couleurs du ColorScheme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black54),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
  ),
),

// --- Thème Sombre ---
darkTheme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.dark,
    // Optionnel : tu peux ajuster la couleur de surface si c'est trop sombre
    surface: const Color(0xFF1E1E1E), 
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    backgroundColor: Color(0xFF121212),
    foregroundColor: Colors.white,
  ),
),

      // Mode de thème par défaut (suit le système du téléphone)
      themeMode: ThemeMode.system, 

      home: const LoginScreen(),
    );
  }
}