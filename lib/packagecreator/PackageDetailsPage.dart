import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'EditAIPackagePage.dart';
import '../root_pages/trip_pages/UserGoogleMapPageCustom.dart';

class PackageDetailsPage extends StatelessWidget {
  final String userKey;
  final String packageKey; // Key to manage the package
  final String packageName;
  final List<Map<String, dynamic>> attractions;
  final List<String> categories;
  final double minRating;

  const PackageDetailsPage({
    Key? key,
    required this.userKey,
    required this.packageKey,
    required this.packageName,
    required this.attractions,
    required this.categories,
    required this.minRating,
  }) : super(key: key);

  /// Start the trip by navigating to the map page
  void _startTrip(BuildContext context) {
    final List<Map<String, dynamic>> tripAttractions = attractions
        .where((site) => site.containsKey('latitude') && site.containsKey('longitude'))
        .map((site) => {
      'latitude': double.tryParse(site['latitude'].toString()) ?? 0.0,
      'longitude': double.tryParse(site['longitude'].toString()) ?? 0.0,
      'siteName': site['siteName'] ?? 'Unnamed Site',
    })
        .toList();

    if (tripAttractions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserGoogleMapPageCustom(attractions: tripAttractions),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid coordinates found for this trip!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Save the package to Firebase
  Future<void> _savePackage(BuildContext context) async {
    final DatabaseReference aiPackagesRef =
    FirebaseDatabase.instance.ref().child('AIPackages');

    try {
      // Create a new package entry in Firebase
      final packageRef = aiPackagesRef.push();
      await packageRef.set({
        'userKey': userKey,
        'packageName': packageName,
        'categories': categories,
        'minRating': minRating,
        'attractions': attractions,
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (error) {
      print('Error saving package: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save the package.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(packageName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: attractions.length,
              itemBuilder: (context, index) {
                final site = attractions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        site['siteImage'] ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported,
                              size: 60, color: Colors.grey);
                        },
                      ),
                    ),
                    title: Text(
                      site['siteName'] ?? 'Unnamed Site',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category: ${site['category']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Rating: ${site['rating']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _startTrip(context),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('Start Trip'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _savePackage(context),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Package'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
