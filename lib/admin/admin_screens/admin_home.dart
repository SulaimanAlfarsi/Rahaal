import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/admin/admin_screens/admin_site/package_details_page.dart';
import 'package:trip/admin/admin_screens/admin_site/seeallattractionsites.dart';
import 'package:trip/admin/admin_screens/admin_site/site_details_page.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final DatabaseReference _attractionRef =
  FirebaseDatabase.instance.ref().child('AttractionSites').child('Muscat');
  final DatabaseReference _packagesRef =
  FirebaseDatabase.instance.ref().child('PreBuiltPackages');

  List<AttractionSite> _sites = [];
  List<Map<String, dynamic>> _packages = [];
  bool _isLoadingSites = true;
  bool _isLoadingPackages = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSites();
    _fetchPackages();
  }

  Future<void> _fetchSites() async {
    try {
      final snapshot = await _attractionRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _sites = data.entries
              .where((entry) => entry.value is Map) // Ensure each entry is a Map
              .map((entry) {
            return AttractionSite.fromJson(Map<String, dynamic>.from(entry.value), entry.key);
          }).toList();
          _isLoadingSites = false;
        });
      } else {
        setState(() {
          _errorMessage = "No attraction sites available.";
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching attraction sites: $e";
        _isLoadingSites = false;
      });
    }
  }


  Future<void> _fetchPackages() async {
    try {
      final snapshot = await _packagesRef.once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          _packages = data.entries
              .map((entry) => {"key": entry.key, ...Map<String, dynamic>.from(entry.value)})
              .toList();
          _isLoadingPackages = false;
        });
      } else {
        setState(() => _isLoadingPackages = false);
      }
    } catch (e) {
      _setError("Error fetching packages: $e");
    }
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoadingSites = false;
      _isLoadingPackages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchSites();
              _fetchPackages();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Attraction Sites',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllAttractionSitesPage(sites: _sites),
                ),
              ),
            ),
            _isLoadingSites
                ? const Center(child: CircularProgressIndicator())
                : _sites.isEmpty
                ? const Center(child: Text('No attraction sites available.'))
                : _buildHorizontalList(
              _sites,
                  (site) => _buildSiteCard(site, context),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Pre-built Packages'),
            _isLoadingPackages
                ? const Center(child: CircularProgressIndicator())
                : _packages.isEmpty
                ? const Center(child: Text('No pre-built packages available.'))
                : _buildHorizontalList(
              _packages,
                  (package) => _buildPackageCard(package, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text('See All', style: TextStyle(color: Colors.blue)),
          ),
      ],
    );
  }

  Widget _buildHorizontalList<T>(List<T> items, Widget Function(T) itemBuilder) {
    if (items.isEmpty) {
      return const Center(child: Text('No items available.'));
    }
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(items[index]),
      ),
    );
  }

  Widget _buildSiteCard(AttractionSite site, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiteDetailsPage(site: site, siteKey: site.key),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: NetworkImage(site.siteImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              site.siteName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PreBuiltPackageDetailsPage(packageKey: package['key']),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                package['packageImage'] ?? '',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                package['packageName'] ?? 'Unnamed Package',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Category: ${package['category'] ?? 'No Category'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
