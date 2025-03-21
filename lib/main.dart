import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

/// A global variable for the API base URL.
/// Change this to 'http://localhost:3000' during development,
/// and to your live deployment URL in production.
String apiBaseUrl = 'http://localhost:3000';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Define initial route and route table
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/coffees': (context) => const CoffeeListPage(),
      },
    );
  }
}

//
// HOME PAGE
//
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // You could store user session data using an AuthService or similar
  static String? authToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee App Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Coffee App!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Log In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/coffees');
              },
              child: const Text('View Coffees'),
            ),
          ],
        ),
      ),
    );
  }
}

//
// SIGNUP PAGE
//
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Please fill in both fields.';
      });
      return;
    }

    try {
      final url = Uri.parse('$apiBaseUrl/signup');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        setState(() {
          _message = 'User created successfully. You can now log in.';
        });
      } else {
        final respData = jsonDecode(response.body);
        setState(() {
          _message = 'Error: ${respData['error'] ?? respData['errors']}';
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
      appBar: AppBar(
        title: const Text('Sign Up'),
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
              onPressed: _signup,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}

//
// LOGIN PAGE
//
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
      // Update the URL here if your backend is mounted on /auth
      final url = Uri.parse('$apiBaseUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final respData = jsonDecode(response.body);
        // Extract the session and access token from the response.
        final session = respData['session'];
        final accessToken = session != null ? session['access_token'] : null;

        setState(() {
          _message = 'Login successful!';
        });

        // Save the token (this example uses a static variable in HomePage).
        HomePage.authToken = accessToken;

        // Navigate to the coffees page.
        Navigator.pushNamed(context, '/coffees');
      } else {
        final respData = jsonDecode(response.body);
        setState(() {
          _message = 'Error: ${respData['error'] ?? 'Unknown error'}';
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

//
// COFFEE LIST PAGE
//
class CoffeeListPage extends StatefulWidget {
  const CoffeeListPage({super.key});

  @override
  State<CoffeeListPage> createState() => _CoffeeListPageState();
}

class _CoffeeListPageState extends State<CoffeeListPage> {
  List coffees = [];
  String errorMessage = '';
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _roastController = TextEditingController(text: 'light');
  final _tasteNotesController = TextEditingController();
  final _originController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCoffees();
  }

  Future<void> _fetchCoffees() async {
    try {
      final url = Uri.parse('$apiBaseUrl/coffees');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          coffees = data;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load coffees. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  Future<void> _createCoffee() async {
    final token = HomePage.authToken;
    if (token == null) {
      setState(() {
        errorMessage = 'You must be logged in to create a coffee.';
      });
      return;
    }

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final roast = _roastController.text.trim();
    final tasteNotes = _tasteNotesController.text.trim();
    final origin = _originController.text.trim();
    final description = _descriptionController.text.trim();

    // Basic validation
    if (name.isEmpty || brand.isEmpty || roast.isEmpty || tasteNotes.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in the required fields.';
      });
      return;
    }

    try {
      final url = Uri.parse('$apiBaseUrl/coffees');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // The backend presumably checks for an Authorization header with Bearer token
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'brand': brand,
          'roast_level': roast,
          'taste_notes': tasteNotes,
          'origin': origin,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        // Successfully created coffee
        _nameController.clear();
        _brandController.clear();
        _roastController.text = 'light';
        _tasteNotesController.clear();
        _originController.clear();
        _descriptionController.clear();

        // Refresh coffee list
        await _fetchCoffees();
        setState(() {
          errorMessage = 'Coffee created successfully!';
        });
      } else {
        final respData = jsonDecode(response.body);
        setState(() {
          errorMessage = 'Error creating coffee: ${respData['error']}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffees'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              const Text('Create a New Coffee (Requires Login)'),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: _roastController,
                decoration: const InputDecoration(
                    labelText: 'Roast Level (light, medium, dark)'),
              ),
              TextField(
                controller: _tasteNotesController,
                decoration: const InputDecoration(labelText: 'Taste Notes'),
              ),
              TextField(
                controller: _originController,
                decoration:
                    const InputDecoration(labelText: 'Origin (optional)'),
              ),
              TextField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _createCoffee,
                child: const Text('Create Coffee'),
              ),
              const Divider(),
              const Text(
                'All Coffees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              for (var coffee in coffees)
                ListTile(
                  title: Text(coffee['name'] ?? 'No name'),
                  subtitle: Text(coffee['brand'] ?? 'No brand'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
