import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/travel_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _selectedRole = 'user';

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inscription réussie !")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur d'inscription.")));
      }
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.teal.shade300),
      filled: true,
      fillColor: Colors.white.withOpacity(0.4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(color: Colors.black54),
      floatingLabelStyle: const TextStyle(color: Colors.teal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TravelBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: const Text("Inscription", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Créer un compte", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: _emailController,
                      decoration: _inputStyle("Email", Icons.email_outlined),
                      validator: (v) => v!.contains('@') ? null : "Email invalide",
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputStyle("Mot de passe", Icons.lock_outline),
                      validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: _inputStyle("Confirmer", Icons.lock_outline),
                      validator: (v) => v != _passwordController.text ? "Ne correspond pas" : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: _inputStyle("Type de compte", Icons.person_outline),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text("Voyageur")),
                        DropdownMenuItem(value: 'admin', child: Text("Administrateur")),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v!),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("S'inscrire", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}