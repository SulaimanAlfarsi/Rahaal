import 'package:flutter/material.dart';
import 'package:trip/root_pages/settingpages/UserDetailsPageBookmarks.dart';
import 'package:trip/root_pages/trip_pages/UserGoogleMapPageCustom.dart';
import 'package:trip/root_pages/userhome/seedetails.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';

class PublicCustomPackageDetailsPage extends StatelessWidget {
  final Map<String, dynamic> package;
  final String userKey;

  const PublicCustomPackageDetailsPage({
    Key? key,
    required this.package,
    required this.userKey,
  }) : super(key: key);

  void _navigateToMap(BuildContext context, List<Map<String, dynamic>> attractions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserGoogleMapPageCustom(attractions: attractions),
      ),
    );
  }

  void _navigateToAttractionDetails(
      BuildContext context, Map<String, dynamic> attraction) {
    final site = AttractionSite.fromJson(attraction, attraction['key'] ?? '');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPageBookmarks(
          site: site,
          userKey: userKey,
        ),
      ),
    );
  }

  Widget _buildPointInfo(BuildContext context, String title, Map<String, dynamic> attraction, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color,
            child: const Icon(Icons.location_pin, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _navigateToAttractionDetails(context, attraction),
                  child: Text(
                    attraction['siteName'] ?? 'Unknown Site',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> attractions = package['attractions'] ?? [];

    // Convert each attraction to Map<String, dynamic> for the map view
    final List<Map<String, dynamic>> formattedAttractions = attractions
        .map((attraction) => Map<String, dynamic>.from(attraction as Map))
        .toList();

    // Extract start and end attractions
    final Map<String, dynamic>? startAttraction =
    formattedAttractions.isNotEmpty ? formattedAttractions.first : null;
    final Map<String, dynamic>? endAttraction =
    formattedAttractions.isNotEmpty ? formattedAttractions.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(package['packageName'] ?? 'Package Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package Creator Info
              Card(
                color: const Color(0xFFF9F9F9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFC8C03),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Created by: ${package['creatorUsername'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Start and End Points Info
              if (startAttraction != null && endAttraction != null)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPointInfo(context, "Start Point", startAttraction, Colors.green),
                        const Divider(thickness: 1, height: 30, color: Colors.grey),
                        _buildPointInfo(context, "End Point", endAttraction, Colors.red),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Attractions List Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'Attractions in this package:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.grey),

              // Attractions List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final attraction = attractions[index] as Map<dynamic, dynamic>;
                  final siteName = attraction['siteName'] ?? 'Unknown Site';
                  final locationImage = attraction['siteImage'] ?? '';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: locationImage.isNotEmpty
                            ? Image.network(
                          locationImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                      title: Text(
                        siteName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      onTap: () => _navigateToAttractionDetails(
                          context, Map<String, dynamic>.from(attraction)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // View on Map Button
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'View on Map',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFFC8C03),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _navigateToMap(context, formattedAttractions),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
