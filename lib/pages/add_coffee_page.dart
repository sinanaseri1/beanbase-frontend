import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class AddCoffeePage extends StatefulWidget {
  const AddCoffeePage({super.key});

  @override
  State<AddCoffeePage> createState() => _AddCoffeePageState();
}

class _AddCoffeePageState extends State<AddCoffeePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _roastController =
      TextEditingController(text: 'light');
  final TextEditingController _tasteNotesController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

  String _errorMessage = '';
  String _successMessage = '';

  Future<void> _pickImage() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedImageBytes = result.files.first.bytes;
          _pickedImageName = result.files.first.name;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _saveCoffee() async {
    setState(() {
      _errorMessage = '';
      _successMessage = '';
    });
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final roast = _roastController.text.trim();
    final tasteNotes = _tasteNotesController.text.trim();
    if (name.isEmpty || brand.isEmpty || roast.isEmpty || tasteNotes.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in the required fields.';
      });
      return;
    }
    final origin = _originController.text.trim();
    final description = _descriptionController.text.trim();
    final coffeeData = {
      'name': name,
      'brand': brand,
      'roast_level': roast,
      'taste_notes': tasteNotes,
      'origin': origin,
      'description': description,
    };

    try {
      if (_pickedImageBytes != null && _pickedImageName != null) {
        final result = await ApiService.createCoffeeWithImage(
          data: coffeeData,
          imageBytes: _pickedImageBytes!,
          filename: _pickedImageName!,
        );
        if (result.containsKey('id')) {
          setState(() {
            _successMessage = 'Coffee created successfully!';
          });
          _clearForm();
        } else {
          setState(() {
            _errorMessage = 'Error: ${result['error']}';
          });
        }
      } else {
        final result = await ApiService.createCoffee(coffeeData);
        if (result.containsKey('id')) {
          setState(() {
            _successMessage = 'Coffee created successfully!';
          });
          _clearForm();
        } else {
          setState(() {
            _errorMessage = 'Error: ${result['error']}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating coffee: $e';
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
    _pickedImageBytes = null;
    _pickedImageName = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Coffee', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Add a Coffee',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.black)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _roastController,
                    decoration: const InputDecoration(
                      labelText: 'Roast Level (light, medium, dark) *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _tasteNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Taste Notes *',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _originController,
                    decoration: const InputDecoration(
                      labelText: 'Origin (Optional)',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text('Pick Image (Optional)',
                        style: TextStyle(color: Colors.white)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveCoffee,
                    child: const Text('Save Coffee',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size(200, 50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(_errorMessage,
                        style: const TextStyle(color: Colors.red)),
                  if (_successMessage.isNotEmpty)
                    Text(_successMessage,
                        style: const TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
