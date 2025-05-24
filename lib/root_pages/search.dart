import 'package:flutter/material.dart';
import 'package:trip/root_pages/serach/SearchAttractionSitesPage.dart';
import 'package:trip/root_pages/serach/SearchByImagePage.dart';
import 'package:trip/root_pages/serach/SearchPreBuiltPackagesPage.dart';

class SearchPage extends StatefulWidget {
  final String userKey;

  const SearchPage({Key? key, required this.userKey}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  void _navigateToSearchAttractionSites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchAttractionSitesPage(userKey: widget.userKey),
      ),
    );
  }

  void _navigateToSearchPreBuiltPackages(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPreBuiltPackagesPage()),
    );
  }

  void _navigateToSearchByImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchByImagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'What would you like to search for?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            _buildSearchOptionButton(
              title: 'Search for Attraction Sites',
              icon: Icons.search,
              color: Colors.blueAccent,
              onTap: () => _navigateToSearchAttractionSites(context),
            ),
            const SizedBox(height: 20),
            _buildSearchOptionButton(
              title: 'Search for Pre-built Packages',
              icon: Icons.workspaces_outline,
              color: Colors.teal,
              onTap: () => _navigateToSearchPreBuiltPackages(context),
            ),
            const SizedBox(height: 20),
            _buildSearchOptionButton(
              title: 'Search Attraction Sites by Image',
              icon: Icons.camera_alt_outlined,
              color: Colors.deepOrange,
              onTap: () => _navigateToSearchByImage(context),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildSearchOptionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
