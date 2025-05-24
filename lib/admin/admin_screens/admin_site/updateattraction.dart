import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';

class EditAttractionSitePage extends StatefulWidget {
  final AttractionSite site;
  final String siteKey;

  const EditAttractionSitePage({Key? key, required this.site, required this.siteKey}) : super(key: key);

  @override
  _EditAttractionSitePageState createState() => _EditAttractionSitePageState();
}

class _EditAttractionSitePageState extends State<EditAttractionSitePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController siteNameController;
  late TextEditingController siteImageController;
  late TextEditingController descriptionController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  String selectedState = "Muscat";
  String selectedCategory = "Historical Sites";

  final List<String> states = [
    "Muscat",
    "Muttrah",
    "Seeb",
    "Bawshar",
    "Al Amerat",
    "Qurayyat",
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
    "Health & Wellness",
  ];

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    siteNameController = TextEditingController(text: widget.site.siteName);
    siteImageController = TextEditingController(text: widget.site.siteImage);
    descriptionController = TextEditingController(text: widget.site.description);
    latitudeController = TextEditingController(text: widget.site.latitude.toString());
    longitudeController = TextEditingController(text: widget.site.longitude.toString());
    selectedState = widget.site.state;
    selectedCategory = widget.site.category;
  }

  Future<void> _updateSite() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // Check for duplicate site name (ignore the current site during check)
        bool isDuplicate = await AttractionSite.checkDuplicateSite(siteNameController.text.trim());
        if (isDuplicate && siteNameController.text.trim() != widget.site.siteName) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Site name already exists!'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        // Create the updated AttractionSite object
        AttractionSite updatedSite = AttractionSite(
          government: 'Muscat',
          state: selectedState,
          siteName: siteNameController.text.trim(),
          category: selectedCategory,
          siteImage: siteImageController.text.trim(),
          description: descriptionController.text.trim(),
          latitude: double.tryParse(latitudeController.text) ?? 0.0,
          longitude: double.tryParse(longitudeController.text) ?? 0.0,
          key: widget.siteKey,
        );

        // Update the site in Firebase
        await AttractionSite.updateAttractionSite(widget.siteKey, updatedSite);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attraction site updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Navigate back after successful update
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating site: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Attraction Site')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // State dropdown
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(labelText: 'State'),
                items: states.map((String state) {
                  return DropdownMenuItem(value: state, child: Text(state));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedState = value!;
                  });
                },
              ),
              // Site name
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
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              // Site image URL
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
              // Description
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
              // Latitude
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
              // Longitude
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
              ElevatedButton(
                onPressed: _isProcessing ? null : _updateSite,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text('Update Site'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
