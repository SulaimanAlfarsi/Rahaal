import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/root_pages/userhome/prebuiltPakageUser.dart';

class SearchPreBuiltPackagesPage extends StatefulWidget {
  const SearchPreBuiltPackagesPage({Key? key}) : super(key: key);

  @override
  State<SearchPreBuiltPackagesPage> createState() =>
      _SearchPreBuiltPackagesPageState();
}

class _SearchPreBuiltPackagesPageState
    extends State<SearchPreBuiltPackagesPage> {
  final DatabaseReference _packagesRef =
  FirebaseDatabase.instance.ref().child('PreBuiltPackages');
  String? _selectedCategory;
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _filteredPackages = [];
  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final snapshot = await _packagesRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _packages = data.entries.map((entry) {
            final packageData = Map<String, dynamic>.from(entry.value as Map);
            return {
              'key': entry.key,
              ...packageData,
            };
          }).toList();
          _filteredPackages = _packages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No Pre-Built Packages found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _errorMessage = "Error fetching packages: $e";
        _isLoading = false;
      });
    }
  }

  void _filterPackages() {
    setState(() {
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        _filteredPackages = _packages.where((package) {
          return package['category']?.toLowerCase() ==
              _selectedCategory!.toLowerCase();
        }).toList();
      } else {
        _filteredPackages = List.from(_packages);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _selectedCategory = null;
      _filteredPackages = List.from(_packages);
    });
  }

  void _navigateToPackageDetails(String? packageKey) {
    if (packageKey != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PreBuiltPackageDetailsUserPage(packageKey: packageKey),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Package details not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Pre-Built Packages'),
        actions: [
          if (_selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear Search',
              onPressed: _clearSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
              hint: const Text("Select a category"),
              isExpanded: true,
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _filterPackages();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(strokeWidth: 3.0),
              ),
            )
                : _errorMessage != null
                ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    fontSize: 16, color: Colors.red),
              ),
            )
                : _filteredPackages.isEmpty
                ? const Center(
              child: Text(
                'No packages found for the selected category.',
                style:
                TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredPackages.length,
              itemBuilder: (context, index) {
                final package = _filteredPackages[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        package['packageImage']?.isNotEmpty ==
                            true
                            ? package['packageImage']
                            : 'https://via.placeholder.com/60',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      package['packageName'] ??
                          'Unnamed Package',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      package['category'] ?? 'No Category',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => _navigateToPackageDetails(
                        package['key']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
