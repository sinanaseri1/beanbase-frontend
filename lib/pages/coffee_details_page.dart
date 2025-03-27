import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CoffeeDetailsPage extends StatefulWidget {
  const CoffeeDetailsPage({super.key});

  @override
  State<CoffeeDetailsPage> createState() => _CoffeeDetailsPageState();
}

class _CoffeeDetailsPageState extends State<CoffeeDetailsPage> {
  Map<String, dynamic>? _coffee;
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final coffeeId = ModalRoute.of(context)!.settings.arguments as String?;
    if (coffeeId != null) {
      _loadCoffeeDetails(coffeeId);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No coffee selected.';
      });
    }
  }

  Future<void> _loadCoffeeDetails(String coffeeId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final coffeeData = await ApiService.fetchCoffeeById(coffeeId);
      _coffee = coffeeData;
      await _loadReviews(coffeeId);
    } catch (e) {
      _errorMessage = 'Error loading coffee: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviews(String coffeeId) async {
    try {
      final reviewList = await ApiService.fetchReviewsForCoffee(coffeeId);
      _reviews = reviewList;
    } catch (e) {
      _errorMessage = 'Error loading reviews: $e';
    }
  }

  Future<void> _submitReview() async {
    final token = AuthService.authToken;
    if (token == null) {
      setState(() {
        _errorMessage = 'You must be logged in to leave a review.';
      });
      return;
    }
    if (_coffee == null) return;
    if (_reviewController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a comment.';
      });
      return;
    }
    try {
      await ApiService.createReview({
        'coffee_id': _coffee!['id'],
        'rating': _rating,
        'comment': _reviewController.text.trim(),
      });
      _reviewController.clear();
      await _loadReviews(_coffee!['id'].toString());
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to submit review: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final coffee = _coffee;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('Coffee Details', style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : coffee == null
                  ? const Center(
                      child: Text('No coffee found.',
                          style: TextStyle(color: Colors.black)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: coffee['image_url'] != null
                                ? Image.network(
                                    coffee['image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image,
                                          color: Colors.black),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image,
                                        color: Colors.black),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            coffee['name'] ?? 'Untitled Coffee',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            coffee['brand'] ?? 'Unknown Brand',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Roast Level: ${coffee['roast_level'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          if (coffee['origin'] != null &&
                              coffee['origin'].toString().isNotEmpty)
                            Text('Origin: ${coffee['origin']}',
                                style: const TextStyle(color: Colors.black)),
                          if (coffee['description'] != null &&
                              coffee['description'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(coffee['description'],
                                  style: const TextStyle(color: Colors.black)),
                            ),
                          const Divider(height: 32, color: Colors.black54),
                          Text('Reviews',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.black)),
                          const SizedBox(height: 8),
                          if (_reviews.isEmpty)
                            const Text('No reviews yet.',
                                style: TextStyle(color: Colors.black))
                          else
                            Column(
                              children: _reviews.map((review) {
                                final rating = review['rating'] ?? 0;
                                final comment = review['comment'] ?? '';
                                final user =
                                    review['users']?['email'] ?? 'Anonymous';
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          for (int i = 1; i <= 5; i++)
                                            Icon(
                                                i <= rating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 20),
                                          const Spacer(),
                                          Text(user,
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(comment,
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 16),
                          _buildReviewForm(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildReviewForm() {
    final token = AuthService.authToken;
    if (token == null) {
      return const Text('Log in to leave a review.',
          style: TextStyle(color: Colors.black54));
    }
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Leave a Review',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rating: ', style: TextStyle(color: Colors.black)),
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(i <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber, size: 20),
                    onPressed: () => setState(() => _rating = i),
                  ),
              ],
            ),
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Your Comments',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(150, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
