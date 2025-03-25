import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please fill in both fields.';
      });
      return;
    }

    try {
      final result = await ApiService.login(email, password);

      // { user: {...}, session: {...} }
      if (result.containsKey('session')) {
        final session = result['session'];
        final accessToken = session['access_token'];

        // Save token globally (simple example).
        AuthService.authToken = accessToken;

        setState(() {
          _message = 'Login successful!';
        });

        // Navigate to coffees page.
        Navigator.pushNamed(context, '/coffees');
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
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Log In'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
