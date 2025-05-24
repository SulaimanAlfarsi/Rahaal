import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/packagecreator/EditAIPackagePage.dart';
import 'package:trip/root_pages/trip_pages/UserGoogleMapPageCustom.dart';

class MyAIPackagesPage extends StatefulWidget {
  final String userKey;

  const MyAIPackagesPage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<MyAIPackagesPage> createState() => _MyAIPackagesPageState();
}

class _MyAIPackagesPageState extends State<MyAIPackagesPage> {
  final DatabaseReference _aiPackagesRef =
  FirebaseDatabase.instance.ref().child('AIPackages');
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  /// Fetch AI Packages
  Future<void> _fetchPackages() async {
    try {
      final snapshot = await _aiPackagesRef.get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> fetchedPackages = [];

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic> && value['userKey'] == widget.userKey) {
            fetchedPackages.add({
              'key': key,
              'packageName': value['packageName'] ?? 'Unnamed Package',
              'attractions': _parseAttractions(value['attractions']),
              'categories': List<String>.from(value['categories'] ?? []),
              'createdAt': value['createdAt'] ?? '',
              'minRating': (value['minRating'] is num)
                  ? value['minRating'].toDouble()
                  : 0.0,
            });
          }
        });

        fetchedPackages.sort((a, b) {
          final createdAtA =
              DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
          final createdAtB =
              DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
          return createdAtB.compareTo(createdAtA);
        });

        setState(() {
          _packages = fetchedPackages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _packages = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching AI Packages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Parse Attractions
  List<Map<String, dynamic>> _parseAttractions(dynamic attractionsData) {
    if (attractionsData is List) {
      return attractionsData.map((e) {
        if (e is Map<dynamic, dynamic>) {
          return e.map((key, value) => MapEntry(key.toString(), value));
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  /// Navigate to Edit Page
  void _navigateToEditPage(Map<String, dynamic> package) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAIPackagePage(
          userKey: widget.userKey,
          packageKey: package['key'],
          packageName: package['packageName'],
          attractions: package['attractions'],
          categories: package['categories'],
          minRating: package['minRating'],
        ),
      ),
    );

    if (isUpdated == true) {
      _fetchPackages();
    }
  }

  /// Confirm Delete Package
  void _confirmDeletePackage(String packageKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Package'),
          content: const Text('Are you sure you want to delete this package?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deletePackage(packageKey);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Delete Package
  Future<void> _deletePackage(String packageKey) async {
    try {
      await _aiPackagesRef.child(packageKey).remove();
      setState(() {
        _packages.removeWhere((package) => package['key'] == packageKey);
      });
    } catch (e) {
      print('Error deleting package: $e');
    }
  }

  /// Navigate to Map
  void _navigateToMap(List<Map<String, dynamic>> attractions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserGoogleMapPageCustom(attractions: attractions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My AI Packages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
          ? const Center(
        child: Text(
          'No AI packages found.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final package = _packages[index];
          final packageName = package['packageName'];
          final attractions = package['attractions'];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    packageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeletePackage(package['key']),
                        tooltip: 'Delete Package',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToEditPage(package),
                        tooltip: 'Edit Package',
                      ),
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.green),
                        onPressed: () => _navigateToMap(attractions),
                        tooltip: 'View on Map',
                      ),
                    ],
                  ),
                ),
                if (attractions.isNotEmpty)
                  Container(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: attractions.length,
                      itemBuilder: (context, i) {
                        final attraction = attractions[i];

                        return Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  attraction['siteImage'] ?? '',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                attraction['siteName'] ?? 'Unknown',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
