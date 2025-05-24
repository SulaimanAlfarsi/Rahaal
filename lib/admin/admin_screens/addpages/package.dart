import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/PreBuiltPackage.dart';

class AdminPrebuiltPackagesPage extends StatefulWidget {
  const AdminPrebuiltPackagesPage({Key? key}) : super(key: key);

  @override
  State<AdminPrebuiltPackagesPage> createState() =>
      _AdminPrebuiltPackagesPageState();
}

class _AdminPrebuiltPackagesPageState extends State<AdminPrebuiltPackagesPage> {
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _packageImageController = TextEditingController(); // Package Image URL field
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? _selectedCategory;
  String? _selectedVisibility = 'public';
  List<Map<String, dynamic>> attractions = [];

  final List<String> categories = [
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


  void _savePackage() {
    final packageName = _packageNameController.text.trim();
    final packageImage = _packageImageController.text.trim();

    if (packageName.isNotEmpty &&
        _selectedCategory != null &&
        attractions.isNotEmpty &&
        packageImage.isNotEmpty) {
      final package = PreBuiltPackage(
        key: '',
        packageName: packageName,
        category: _selectedCategory!,
        visibility: _selectedVisibility!,
        attractions: attractions,
        packageImage: packageImage,
      );

      PreBuiltPackage.addPackage(package).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package added successfully')),
        );
        _resetForm();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding package: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  // Reset the form after saving the package
  void _resetForm() {
    setState(() {
      _packageNameController.clear();
      _packageImageController.clear();
      _siteNameController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _imageUrlController.clear();
      _selectedCategory = null;
      attractions.clear();
    });
  }

  // Add a new attraction to the list
  void _addAttraction() {
    final siteName = _siteNameController.text.trim();
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    final imageUrl = _imageUrlController.text.trim();

    if (siteName.isNotEmpty &&
        latitude != null &&
        longitude != null &&
        imageUrl.isNotEmpty) {
      setState(() {
        attractions.add({
          'siteName': siteName,
          'latitude': latitude,
          'longitude': longitude,
          'imageUrl': imageUrl,
        });


        _siteNameController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
        _imageUrlController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all attraction details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Pre-built Package')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _packageNameController,
              decoration: const InputDecoration(labelText: 'Package Name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              items: categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedVisibility,
              hint: const Text('Select Visibility'),
              items: ['public', 'private'].map((String visibility) {
                return DropdownMenuItem(
                  value: visibility,
                  child: Text(visibility.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVisibility = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _packageImageController,
              decoration: const InputDecoration(labelText: 'Package Image URL'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Attractions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _siteNameController,
              decoration: const InputDecoration(labelText: 'Site Name'),
            ),
            TextField(
              controller: _latitudeController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _longitudeController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            ElevatedButton(
              onPressed: _addAttraction,
              child: const Text('Add Attraction'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final site = attractions[index];
                  return ListTile(
                    title: Text(site['siteName']),
                    subtitle: Text(
                        'Lat: ${site['latitude']}, Lng: ${site['longitude']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          attractions.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _savePackage,
              child: const Text('Add Pre-built Package'),
            ),
          ],
        ),
      ),
    );
  }
}
