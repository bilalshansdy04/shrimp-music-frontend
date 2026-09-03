import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/auth_provider.dart";

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username and password are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await ref.read(authProvider.notifier).login(username, password);
      } else {
        await ref.read(authProvider.notifier).register(username, password);
      }
      if (mounted) Navigator.of(context).pop(); // Go back to previous screen
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? "Login" : "Register"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                "Shrimp Music",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create playlists to save your favorite songs.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(_isLogin ? "Login" : "Register", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


