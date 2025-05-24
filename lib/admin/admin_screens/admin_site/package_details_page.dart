import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/admin_screens/admin_site/UpdatePackagePage.dart';
import 'package:trip/admin/admin_screens/admin_site/googlemappage.dart';

class PreBuiltPackageDetailsPage extends StatefulWidget {
  final String packageKey;

  const PreBuiltPackageDetailsPage({
    Key? key,
    required this.packageKey,
  }) : super(key: key);

  @override
  _PreBuiltPackageDetailsPageState createState() =>
      _PreBuiltPackageDetailsPageState();
}

class _PreBuiltPackageDetailsPageState
    extends State<PreBuiltPackageDetailsPage> {
  final DatabaseReference _packagesRef =
  FirebaseDatabase.instance.ref().child('PreBuiltPackages');

  Map<String, dynamic>? _packageDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPackageDetails();
  }

  Future<void> _fetchPackageDetails() async {
    try {
      final snapshot = await _packagesRef.child(widget.packageKey).once();
      if (snapshot.snapshot.value != null) {
        final data = (snapshot.snapshot.value as Map).cast<String, dynamic>();
        setState(() {
          _packageDetails = data;
          _isLoading = false;
        });
      } else {
        _setError('Package details not found.');
      }
    } catch (e) {
      _setError('Error fetching package details: $e');
    }
  }

  Future<void> _deletePackage() async {
    try {
      await _packagesRef.child(widget.packageKey).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package deleted successfully')),
      );
      Navigator.pop(context); // Go back after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting package: $e')),
      );
    }
  }

  void _confirmDelete() {
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _deletePackage();
              },
            ),
          ],
        );
      },
    );
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdatePackagePage(
                    packageKey: widget.packageKey,
                    packageDetails: _packageDetails!,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _buildPackageDetails(),
    );
  }

  Widget _buildPackageDetails() {
    final attractions = _packageDetails?['attractions'] ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _packageDetails?['packageName'] ?? 'Unnamed Package',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${_packageDetails?['category'] ?? 'No Category'}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text('Attractions:', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: attractions.length,
              itemBuilder: (context, index) {
                final attraction = Map<String, dynamic>.from(attractions[index]);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.network(
                      attraction['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(attraction['siteName']),
                    subtitle: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoogleMapsPage(
                            latitude: attraction['latitude'],
                            longitude: attraction['longitude'],
                          ),
                        ),
                      ),
                      child: const Text(
                        'View on Map',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
