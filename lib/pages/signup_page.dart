import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields.';
      });
      return;
    }
    try {
      final result = await ApiService.signup(email, password);
      if (result.containsKey('user')) {
        setState(() {
          _message = 'Account created successfully. You can now log in.';
        });
      } else {
        setState(() {
          _message = 'Error: ${result['error'] ?? result['errors']}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Signup failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.black)),
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
                Text('Sign Up',
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
                  onPressed: _signup,
                  child: const Text('Sign Up',
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
