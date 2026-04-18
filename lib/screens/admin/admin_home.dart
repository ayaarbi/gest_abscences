import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'etudiants_screen.dart';
import 'enseignants_screen.dart';
import 'classes_screen.dart';
import 'seances_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Administration GestAbsence"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.school), text: "Etudiants"),
              Tab(icon: Icon(Icons.person), text: "Enseignants"),
              Tab(icon: Icon(Icons.class_), text: "Classes"),
              Tab(icon: Icon(Icons.calendar_today), text: "Séances"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EtudiantsScreen(),
            EnseignantsScreen(),
            ClassesScreen(),
            SeancesScreen(),
          ],
        ),
      ),
    );
  }
}