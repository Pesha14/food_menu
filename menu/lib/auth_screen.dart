import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'services/api_service.dart';
import 'menu_screen.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _passwordController = TextEditingController();
  final String _testCredential = "test21";

  Future<void> _handleAuth() async {
    // Development simulation
    final success = _passwordController.text == _testCredential;
    
    if (mounted) {
      if (success) {
        // Pass staff name to MenuScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MenuScreen(staffName: _testCredential)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Credentials (use: test21)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Menu System', style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFF000080))),
              const SizedBox(height: 40),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock, color: Color(0xFF000080))), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleAuth,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000080), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
