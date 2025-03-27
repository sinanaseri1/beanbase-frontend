import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CoffeeListPage extends StatefulWidget {
  const CoffeeListPage({super.key});

  @override
  State<CoffeeListPage> createState() => _CoffeeListPageState();
}

class _CoffeeListPageState extends State<CoffeeListPage> {
  List coffees = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCoffees();
  }

  Future<void> _loadCoffees() async {
    try {
      final data = await ApiService.fetchCoffees();
      setState(() {
        coffees = data;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching coffees: $e';
      });
    }
  }

  void _logout() {
    // Clear token and navigate to home.
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final token = AuthService.authToken;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Coffee Collection',
            style: TextStyle(color: Colors.black)),
        actions: [
          if (token != null)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, '/add-coffee')
                  .then((_) => _loadCoffees()),
              icon: const Icon(Icons.add, color: Colors.black),
              tooltip: 'Add Coffee',
            ),
          if (token != null)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.black),
              tooltip: 'Logout',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: errorMessage.isNotEmpty
            ? Center(
                child: Text(errorMessage,
                    style: const TextStyle(color: Colors.red)))
            : coffees.isEmpty
                ? const Center(
                    child: Text('No coffees found.',
                        style: TextStyle(color: Colors.black)))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: coffees.length,
                    itemBuilder: (context, index) {
                      final coffee = coffees[index];
                      final imageUrl = coffee['image_url'] as String?;
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/coffee-details',
                            arguments: coffee['id'].toString(),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.black),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image,
                                              color: Colors.black),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      coffee['name'] ?? 'No Name',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      coffee['brand'] ?? 'No Brand',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
