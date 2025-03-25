import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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

  // Text controllers for coffee fields
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _roastController = TextEditingController(text: 'light');
  final _tasteNotesController = TextEditingController();
  final _originController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Image data
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  @override
  void initState() {
    super.initState();
    _fetchCoffees();
  }

  Future<void> _fetchCoffees() async {
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

  Future<void> _createCoffee() async {
    try {
      final name = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final roastLevel = _roastController.text.trim();
      final tasteNotes = _tasteNotesController.text.trim();
      final origin = _originController.text.trim();
      final description = _descriptionController.text.trim();

      if (name.isEmpty ||
          brand.isEmpty ||
          roastLevel.isEmpty ||
          tasteNotes.isEmpty) {
        setState(() {
          errorMessage = 'Please fill in the required fields.';
        });
        return;
      }

      final result = await ApiService.createCoffee(
        name: name,
        brand: brand,
        roastLevel: roastLevel,
        tasteNotes: tasteNotes,
        origin: origin.isEmpty ? null : origin,
        description: description.isEmpty ? null : description,
      );

      if (result.containsKey('id')) {
        _clearForm();
        await _fetchCoffees();
        setState(() {
          errorMessage = 'Coffee created successfully (no image).';
        });
      } else {
        setState(() {
          errorMessage = 'Error creating coffee: ${result['error']}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error creating coffee: $e';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedImageBytes = result.files.first.bytes;
          _pickedImageName = result.files.first.name;
          errorMessage = 'Image selected: $_pickedImageName';
        });
      } else {
        setState(() {
          errorMessage = 'No image selected.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _createCoffeeWithImage() async {
    if (_pickedImageBytes == null || _pickedImageName == null) {
      setState(() {
        errorMessage = 'Please pick an image first.';
      });
      return;
    }

    try {
      final name = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final roastLevel = _roastController.text.trim();
      final tasteNotes = _tasteNotesController.text.trim();
      final origin = _originController.text.trim();
      final description = _descriptionController.text.trim();

      if (name.isEmpty ||
          brand.isEmpty ||
          roastLevel.isEmpty ||
          tasteNotes.isEmpty) {
        setState(() {
          errorMessage = 'Please fill in required text fields.';
        });
        return;
      }

      final result = await ApiService.createCoffeeWithImage(
        name: name,
        brand: brand,
        roastLevel: roastLevel,
        tasteNotes: tasteNotes,
        origin: origin.isEmpty ? null : origin,
        description: description.isEmpty ? null : description,
        imageBytes: _pickedImageBytes!,
        filename: _pickedImageName!,
      );

      if (result.containsKey('id')) {
        _clearForm();
        _pickedImageBytes = null;
        _pickedImageName = null;
        await _fetchCoffees();
        setState(() {
          errorMessage = 'Coffee created successfully with image!';
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${result['error']}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception creating coffee with image: $e';
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _brandController.clear();
    _roastController.text = 'light';
    _tasteNotesController.clear();
    _originController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final token = AuthService.authToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffees'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (token == null)
              const Text(
                'Note: You are not logged in. You cannot create coffees.',
                style: TextStyle(color: Colors.orange),
              ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),

            // Form fields
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *'),
            ),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: 'Brand *'),
            ),
            TextField(
              controller: _roastController,
              decoration: const InputDecoration(
                labelText: 'Roast Level (light, medium, dark) *',
              ),
            ),
            TextField(
              controller: _tasteNotesController,
              decoration: const InputDecoration(labelText: 'Taste Notes *'),
            ),
            TextField(
              controller: _originController,
              decoration: const InputDecoration(labelText: 'Origin (optional)'),
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createCoffee,
                    child: const Text('Create Coffee (No Image)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _createCoffeeWithImage,
              child: const Text('Create Coffee With Image'),
            ),

            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'All Coffees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var coffee in coffees) ...[
              ListTile(
                title: Text(coffee['name'] ?? 'No name'),
                subtitle: Text(coffee['brand'] ?? 'No brand'),
                trailing: coffee['image_url'] != null
                    ? Image.network(
                        coffee['image_url'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              const Divider(),
            ]
          ],
        ),
      ),
    );
  }
}
