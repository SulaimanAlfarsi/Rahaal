import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/admin/admin_screens/admin_site/googlemappage.dart';
import 'package:trip/admin/admin_screens/admin_site/updateattraction.dart';

class SiteDetailsPage extends StatelessWidget {
  final AttractionSite site;
  final String siteKey;

  const SiteDetailsPage({Key? key, required this.site, required this.siteKey}) : super(key: key);

  Future<void> _deleteSite(BuildContext context, String siteKey) async {
    final bool confirm = await _showDeleteConfirmationDialog(context);
    if (confirm) {
      await AttractionSite.deleteAttractionSite(siteKey);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attraction site deleted successfully!'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return (await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this site?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(site.siteName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  site.siteImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Site Name
              Text(
                site.siteName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Category
              Text(
                'Category: ${site.category}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                site.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Location (Clickable to View on Map)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleMapsPage(
                        latitude: site.latitude,
                        longitude: site.longitude,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'View on Map',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              // Edit and Delete Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Site'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditAttractionSitePage(
                              site: site,
                              siteKey: siteKey
                          ),
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete Site'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _deleteSite(context, siteKey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
