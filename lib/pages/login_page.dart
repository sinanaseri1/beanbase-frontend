import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields.';
      });
      return;
    }
    try {
      final result = await ApiService.login(email, password);
      if (result.containsKey('session')) {
        final session = result['session'];
        final accessToken = session['access_token'];
        // Store token in AuthService.
        // (For a real app, consider secure storage.)
        AuthService.authToken = accessToken;
        setState(() {
          _message = 'Login successful!';
        });
        Navigator.pushReplacementNamed(context, '/coffees');
      } else {
        setState(() {
          _message = 'Error: ${result['error'] ?? "Unknown error"}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Login failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Log In', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Log In',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.black)),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50)),
                  onPressed: _login,
                  child: const Text('Log In',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                Text(_message, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
