import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'trip_pages/ViewCustomPackagesPage.dart';

class CreateCustomPackagePage extends StatefulWidget {
  final String userId;

  const CreateCustomPackagePage({Key? key, required this.userId}) : super(key: key);

  @override
  _CreateCustomPackagePageState createState() => _CreateCustomPackagePageState();
}

class _CreateCustomPackagePageState extends State<CreateCustomPackagePage> {
  final TextEditingController _packageNameController = TextEditingController();
  final List<AttractionSite> _attractionSites = [];
  final List<AttractionSite> _selectedSites = [];
  bool _isPublic = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAttractionSites();
  }

  Future<void> _fetchAttractionSites() async {
    try {
      final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('AttractionSites').child('Muscat');

      final snapshot = await attractionRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // Debug: Log raw data
        print("Fetched AttractionSites data: $data");

        setState(() {
          _attractionSites.clear();

          // Parse the data into `AttractionSite` objects
          _attractionSites.addAll(
            data.entries
                .where((entry) => entry.value is Map) // Ensure each entry is a Map
                .map((entry) {
              final attractionData = Map<String, dynamic>.from(entry.value);

              return AttractionSite(
                siteName: attractionData['siteName'] ?? 'Unnamed Site',
                siteImage: attractionData['siteImage'] ?? '',
                latitude: double.tryParse(attractionData['latitude']?.toString() ?? '0.0') ?? 0.0,
                longitude: double.tryParse(attractionData['longitude']?.toString() ?? '0.0') ?? 0.0,
                category: attractionData['category'] ?? 'Unknown Category',
                description: attractionData['description'] ?? 'No description available',
                state: attractionData['state'] ?? 'Unknown State',
                key: entry.key, // Use the entry's key as the unique identifier
              );

              return AttractionSite.fromJson(attractionData, entry.key);
            }).toList(),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No attraction sites found.";
          _isLoading = false;
        });
        print(_errorMessage); // Debug
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching attraction sites: $e";
        _isLoading = false;
      });
      print("Error fetching attraction sites: $e"); // Debug
    }
  }



  String normalizeName(String name) {
    return name.replaceAll(' ', '').toLowerCase();
  }

  Future<bool> _isPackageNameDuplicate(String packageName) async {
    final normalizedPackageName = normalizeName(packageName);
    final userPackagesRef = FirebaseDatabase.instance.ref().child('CustomPackages');
    final snapshot = await userPackagesRef.once();

    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      for (var user in data.entries) {
        final userPackages = user.value;
        if (userPackages is Map) {
          for (var package in userPackages.values) {
            if (normalizeName(package['packageName']) == normalizedPackageName) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _toggleSelection(AttractionSite site) {
    setState(() {
      if (_selectedSites.contains(site)) {
        _selectedSites.remove(site);
      } else if (_selectedSites.length < 5) {
        _selectedSites.add(site);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 5 attractions only")),
        );
      }
    });
  }

  Future<void> _confirmSavePackage() async {
    final packageName = _packageNameController.text.trim();

    if (packageName.isEmpty) {
      setState(() {
        _errorMessage = "Package name cannot be empty";
      });
      return;
    } else if (_selectedSites.length < 2) {
      setState(() {
        _errorMessage = "Please select at least 2 attraction sites";
      });
      return;
    } else if (await _isPackageNameDuplicate(packageName)) {
      setState(() {
        _errorMessage = "Package name already exists. Please choose a different name.";
      });
      return;
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    final userPackagesRef =
    FirebaseDatabase.instance.ref().child('CustomPackages').child(widget.userId);
    final snapshot = await userPackagesRef.once();
    final packageCount = (snapshot.snapshot.value as Map?)?.length ?? 0;

    if (packageCount >= 10) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Package Limit Reached"),
            content: const Text("You have reached the maximum limit of 10 packages."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_isPublic) {
      final confirmPublic = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Public Package"),
            content: const Text("By making this package public, all users will be able to view it."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );

      if (confirmPublic == true) {
        await _savePackage();
      }
    } else {
      await _savePackage();
    }
  }

  Future<void> _savePackage() async {
    try {
      final packageRef = FirebaseDatabase.instance
          .ref()
          .child('CustomPackages')
          .child(widget.userId)
          .push();

      await packageRef.set({
        'packageName': _packageNameController.text.trim(),
        'isPublic': _isPublic,
        'attractions': _selectedSites.map((site) => site.toJson()).toList(),
        'userId': widget.userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Package saved successfully")),
      );

      // Clear the form fields and selections
      setState(() {
        _selectedSites.clear();
        _packageNameController.clear();
        _isPublic = false;
      });
    } catch (e) {
      print("Error saving package: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save package. Please try again.")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Create Custom Package'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _packageNameController,
              decoration: const InputDecoration(
                labelText: 'Package Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          SwitchListTile(
            title: const Text('Make Package Public'),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _attractionSites.length,
              itemBuilder: (context, index) {
                final site = _attractionSites[index];
                final isSelected = _selectedSites.contains(site);
                final selectedIndex = _selectedSites.indexOf(site) + 1;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          site.siteImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        if (isSelected)
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: Text(
                              '$selectedIndex',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    title: Text(site.siteName),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (value) => _toggleSelection(site),
                    ),
                    onTap: () => _toggleSelection(site),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _confirmSavePackage,
                  child: const Text('Save Package'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewCustomPackagesPage(userId: widget.userId),
                      ),
                    );
                  },
                  child: const Text('View My Packages'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
