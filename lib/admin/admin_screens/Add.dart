import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';

class AddAttractionSitePage extends StatefulWidget {
  @override
  _AddAttractionSitePageState createState() => _AddAttractionSitePageState();
}

class _AddAttractionSitePageState extends State<AddAttractionSitePage> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for the form fields
  final TextEditingController siteNameController = TextEditingController();
  final TextEditingController siteImageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Initial selections for dropdowns
  String selectedState = "Muscat";
  String selectedCategory = "Historical Sites";

  // Lists of states and categories for dropdowns
  final List<String> states = [
    "Muscat",
    "Muttrah",
    "Seeb",
    "Bawshar",
    "Al Amerat",
    "Qurayyat"
  ];

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

  bool _isProcessing = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true; // Set loading state
      });

      // Check for duplicate site names
      bool isDuplicate = await AttractionSite.checkDuplicateSite(
        siteNameController.text.trim(),
      );

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site name already exists in the database!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false; // Reset loading state
        });
        return;
      }

      // Create a new AttractionSite object
      AttractionSite newSite = AttractionSite(
        government: 'Muscat',
        state: selectedState,
        siteName: siteNameController.text.trim(),
        category: selectedCategory,
        siteImage: siteImageController.text.trim(),
        description: descriptionController.text.trim(),
        latitude: double.tryParse(latitudeController.text) ?? 0.0,
        longitude: double.tryParse(longitudeController.text) ?? 0.0,
        key: '',
      );

      // Add the new site to Firebase
      await AttractionSite.addAttractionSite(newSite);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attraction site added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form fields
      siteNameController.clear();
      siteImageController.clear();
      descriptionController.clear();
      latitudeController.clear();
      longitudeController.clear();

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Attraction Site"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Government field
              TextFormField(
                initialValue: 'Muscat',
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Government'),
              ),
              // State dropdown
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(labelText: 'State'),
                items: states.map((String state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value!; // Update selected state
                  });
                },
              ),
              // Site Name field
              TextFormField(
                controller: siteNameController,
                decoration: const InputDecoration(labelText: 'Site Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the site name';
                  }
                  return null;
                },
              ),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!; // Update selected category
                  });
                },
              ),
              // Site Image URL field
              TextFormField(
                controller: siteImageController,
                decoration: const InputDecoration(labelText: 'Site Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              // Description field
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              // Latitude field
              TextFormField(
                controller: latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the latitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid latitude';
                  }
                  return null;
                },
              ),
              // Longitude field
              TextFormField(
                controller: longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the longitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid longitude';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Submit button
              ElevatedButton(
                onPressed: _isProcessing ? null : _submitForm,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Add Attraction Site'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
