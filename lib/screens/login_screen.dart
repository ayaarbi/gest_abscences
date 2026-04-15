import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin/admin_home.dart';
import 'enseignant/enseignant_home.dart';
import 'etudiant/etudiant_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false; //pour afficher un loader
  bool _obscure = true; //pour cacher ou afficher le passw

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      //Flutter appel l'api service pour envoyer une requete poste avec email et passw
      final res = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (res['success'] == 1) {
        final user = res['data'];
        // Sauvegarder la session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', int.parse(user['id'].toString()));
        await prefs.setString('role', user['role']);
        await prefs.setString('nom', user['nom']);

        // Rediriger selon le rôle
        if (!mounted) return;
        final id = int.parse(user['id'].toString());
        Widget dest;
        if (user['role'] == 'admin'){
          dest = const AdminHome();
        }         
        else if (user['role'] == 'enseignant'){
          //dest = EnseignantHome(userId: id);
          dest = EnseignantHome();
        }
        else{
          //dest = EtudiantHome(userId: id);
          dest = EtudiantHome();
        }                                   

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
      } else {
        _showSnack(res['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      _showSnack('Impossible de joindre le serveur');
    }
    setState(() => _loading = false);
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.indigo),
              const SizedBox(height: 16),
              Text('GestAbsence', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}