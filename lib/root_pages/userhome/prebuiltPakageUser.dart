import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/root_pages/userhome/GoogleMapPrebuiltPackagePage.dart';
import 'package:trip/root_pages/userhome/googlemapuser.dart';

class PreBuiltPackageDetailsUserPage extends StatefulWidget {
  final String packageKey;

  const PreBuiltPackageDetailsUserPage({
    Key? key,
    required this.packageKey,
  }) : super(key: key);

  @override
  _PreBuiltPackageDetailsUserPageState createState() =>
      _PreBuiltPackageDetailsUserPageState();
}

class _PreBuiltPackageDetailsUserPageState
    extends State<PreBuiltPackageDetailsUserPage> {
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
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);

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
        backgroundColor: Color(0xFFE07518),
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

    // Get start and end points
    final startPoint = attractions.isNotEmpty ? attractions.first : null;
    final endPoint = attractions.isNotEmpty ? attractions.last : null;

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
          if (startPoint != null || endPoint != null)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (startPoint != null)
                      ListTile(
                        leading: const Icon(Icons.flag, color: Colors.green),
                        title: Text(
                          'Start Point: ${startPoint['siteName']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    const Divider(),
                    if (endPoint != null)
                      ListTile(
                        leading: const Icon(Icons.flag, color: Colors.red),
                        title: Text(
                          'End Point: ${endPoint['siteName']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),
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
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        attraction['imageUrl'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      attraction['siteName'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserGoogleMapPage(
                            latitude: attraction['latitude'],
                            longitude: attraction['longitude'],
                          ),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.map, color: Colors.blue, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'View on Map',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),

                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Only add valid latitude and longitude coordinates
                List<Map<String, double>> coordinates = [];
                for (var attraction in attractions) {
                  if (attraction['latitude'] is double &&
                      attraction['longitude'] is double) {
                    coordinates.add({
                      'latitude': attraction['latitude'],
                      'longitude': attraction['longitude'],
                    });
                  }
                }

                if (coordinates.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMapPrebuiltPackagePage(
                        coordinates: coordinates,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No valid coordinates found.'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE07518),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Start Trip',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
