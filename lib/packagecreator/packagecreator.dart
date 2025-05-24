import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/packagecreator/MyAIPackagesPage.dart';
import 'PackageDetailsPage.dart';
import 'dart:math';

class PackageCreatorPage extends StatefulWidget {
  final String userKey;

  const PackageCreatorPage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<PackageCreatorPage> createState() => _PackageCreatorPageState();
}

class _PackageCreatorPageState extends State<PackageCreatorPage> {
  final DatabaseReference _attractionsRef =
  FirebaseDatabase.instance.ref().child('AttractionSites');

  final List<String> _categories = [
    "Historical Sites",
    "Cultural Heritage",
    "Natural Attractions",
    "Religious Sites",
    "Adventure & Outdoor Activities",
    "Parks & Gardens",
    "Beaches & Resorts",
    "Shopping & Souqs",
    "Cultural Festivals & Events",
    "Modern Attractions",
    "Wildlife & Eco-tourism",
    "Arts & Entertainment",
    "Sports & Recreation",
    "Health & Wellness"
  ];

  List<String> _selectedCategories = [];
  int _siteCount = 2;
  double _selectedRating = 0.0;
  bool _isLoading = false;

  final TextEditingController _packageNameController = TextEditingController();

  /// Check for duplicate package name in AI Packages collection
  Future<bool> _isDuplicatePackageName(String packageName) async {
    final snapshot = await FirebaseDatabase.instance
        .ref()
        .child('AIPackages')
        .orderByChild('packageName')
        .equalTo(packageName)
        .once();

    return snapshot.snapshot.exists;
  }

  /// Generate Package
  Future<void> _generatePackage() async {
    if (_packageNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter a package name.');
      return;
    }

    if (await _isDuplicatePackageName(_packageNameController.text.trim())) {
      _showSnackBar('Package name already exists. Choose a different name.');
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, List<Map<String, dynamic>>> categoryAttractions = {};
    final List<Map<String, dynamic>> finalPackage = [];

    try {
      for (String state in [
        'Muscat',
        'Muttrah',
        'Seeb',
        'Bawshar',
        'Al Amerat',
        'Qurayyat'
      ]) {
        final stateRef = _attractionsRef.child(state);
        final snapshot = await stateRef.get();

        if (snapshot.exists && snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

          for (var entry in data.entries) {
            if (entry.value is Map<dynamic, dynamic>) {
              final attraction = Map<String, dynamic>.from(entry.value);
              final String category = attraction['category'] ?? '';
              final double rating =
                  (attraction['rating'] as num?)?.toDouble() ?? 0.0;

              if (_selectedCategories.contains(category) &&
                  rating >= _selectedRating) {
                categoryAttractions.putIfAbsent(category, () => []);
                categoryAttractions[category]!.add({
                  'siteName': attraction['siteName'] ?? 'Unnamed Site',
                  'category': category,
                  'rating': rating,
                  'siteImage': attraction['siteImage'] ?? '',
                  'latitude': attraction['latitude'] ?? '0.0',
                  'longitude': attraction['longitude'] ?? '0.0',
                });
              }
            }
          }
        }
      }

      final totalAvailableSites =
      categoryAttractions.values.fold(0, (sum, list) => sum + list.length);
      if (totalAvailableSites < _siteCount) {
        setState(() => _isLoading = false);
        _showSnackBar(
            'Not enough attractions available to meet the requested site count!');
        return;
      }

      final random = Random();
      final List<Map<String, dynamic>> allAttractions = [];
      _selectedCategories.forEach((category) {
        if (categoryAttractions.containsKey(category)) {
          allAttractions.addAll(categoryAttractions[category]!);
        }
      });

      allAttractions.shuffle(random);
      while (finalPackage.length < _siteCount && allAttractions.isNotEmpty) {
        finalPackage.add(allAttractions.removeLast());
      }

      setState(() => _isLoading = false);

      if (finalPackage.length < _siteCount) {
        _showSnackBar(
            'Could not generate enough sites for the package. Please adjust your criteria!');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PackageDetailsPage(
              userKey: widget.userKey,
              packageKey: '', // Placeholder key for new packages
              packageName: _packageNameController.text.trim(),
              attractions: finalPackage,
              categories: _selectedCategories,
              minRating: _selectedRating,
            ),
          ),
        );
      }
    } catch (error) {
      print("Error: $error");
      setState(() => _isLoading = false);
      _showSnackBar('Error generating package: $error');
    }
  }

  /// Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Category Selection Widget
  Widget _buildCategorySelection() {
    return Wrap(
      spacing: 8.0,
      children: _categories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        final canSelectMore = _selectedCategories.length < 3 || isSelected;

        return FilterChip(
          label: Text(category),
          selected: isSelected,
          onSelected: canSelectMore
              ? (selected) {
            setState(() {
              if (selected) {
                _selectedCategories.add(category);
              } else {
                _selectedCategories.remove(category);
              }
            });
          }
              : null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Package Creator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Categories (Max 3):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildCategorySelection(),
            const SizedBox(height: 20),
            const Text('Minimum Rating:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: _selectedRating,
              min: 0,
              max: 5,
              divisions: 10,
              label: _selectedRating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _selectedRating = value),
            ),
            const SizedBox(height: 20),
            const Text('Number of Sites:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: _siteCount.toDouble(),
              min: 2,
              max: 5,
              divisions: 3,
              label: _siteCount.toString(),
              onChanged: (value) => setState(() => _siteCount = value.toInt()),
            ),
            TextField(
              controller: _packageNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Package Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectedCategories.isNotEmpty && !_isLoading
                        ? _generatePackage
                        : null,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Custom Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAIPackagesPage(userKey: widget.userKey),
                        ),
                      );
                    },
                    icon: const Icon(Icons.folder_special),
                    label: const Text('View My AI Packages'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
