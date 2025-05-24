import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdatePackagePage extends StatefulWidget {
  final String packageKey;
  final Map<String, dynamic> packageDetails;

  const UpdatePackagePage({
    Key? key,
    required this.packageKey,
    required this.packageDetails,
  }) : super(key: key);

  @override
  _UpdatePackagePageState createState() => _UpdatePackagePageState();
}

class _UpdatePackagePageState extends State<UpdatePackagePage> {
  final DatabaseReference _packagesRef =
  FirebaseDatabase.instance.ref().child('PreBuiltPackages');

  late TextEditingController _packageNameController;
  late TextEditingController _packageImageController;
  String? _selectedCategory;
  List<Map<String, dynamic>> attractions = [];

  final List<String> categories = [
    'Historical Sites',
    'Cultural Heritage',
    'Natural Attractions',
    'Adventure & Outdoor Activities',
    'Parks & Gardens',
    'Beaches & Resorts',
    'Shopping & Souqs',
    'Cultural Festivals & Events',
    'Modern Attractions',
    'Wildlife & Eco-tourism',
    'Arts & Entertainment',
    'Sports & Recreation',
    'Health & Wellness'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _packageNameController = TextEditingController(
      text: widget.packageDetails['packageName'] ?? '',
    );
    _packageImageController = TextEditingController(
      text: widget.packageDetails['packageImage'] ?? '',
    );

    final List<dynamic> attractionsData =
        widget.packageDetails['attractions'] ?? [];
    attractions =
        attractionsData.map((e) => Map<String, dynamic>.from(e)).toList();

    _selectedCategory = categories.contains(widget.packageDetails['category'])
        ? widget.packageDetails['category']
        : null;
  }

  Future<void> _updatePackage() async {
    try {
      await _packagesRef.child(widget.packageKey).update({
        'packageName': _packageNameController.text,
        'packageImage': _packageImageController.text,
        'category': _selectedCategory,
        'attractions': attractions,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating package: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Package'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _packageNameController,
              decoration: const InputDecoration(labelText: 'Package Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _packageImageController, // Image URL field
              decoration: const InputDecoration(labelText: 'Package Image URL'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select Category'),
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Attractions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final attraction = attractions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: TextEditingController(
                              text: attraction['siteName'] ?? 'Unnamed Site',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Site Name',
                            ),
                            onChanged: (value) {
                              attraction['siteName'] = value;
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: attraction['latitude'].toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              attraction['latitude'] =
                                  double.tryParse(value) ?? 0.0;
                            },
                          ),
                          TextField(
                            controller: TextEditingController(
                              text: attraction['longitude'].toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              attraction['longitude'] =
                                  double.tryParse(value) ?? 0.0;
                            },
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                attractions.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _updatePackage,
                child: const Text('Update Package'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
