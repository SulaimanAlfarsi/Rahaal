import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/root_pages/userhome/AllAttractionSitesPageforuser.dart';
import 'package:trip/root_pages/userhome/PublicCustomPackageDetailsPage.dart';
import 'package:trip/root_pages/userhome/prebuiltPakageUser.dart';
import 'package:trip/root_pages/userhome/seedetails.dart';

import '../Account/AccountDetailsPage.dart';
import '../packagecreator/packagecreator.dart';

class HomePage extends StatefulWidget {
  final String userKey;

  const HomePage({
    Key? key,
    required this.userKey,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? greetingMessage;
  String? username;
  List<AttractionSite> _sites = [];
  List<AttractionSite> _recommendedSites = [];
  List<Map<String, dynamic>> _prebuiltPackages = [];
  List<Map<String, dynamic>> _publicCustomPackages = [];
  bool _isLoadingSites = true;
  bool _isLoadingPackages = true;
  bool _isLoadingCustomPackages = true;
  String? _errorMessage;
  Map<String, int> _categoryClicks = {};

  @override
  void initState() {
    super.initState();
    _setGreetingMessage();
    _fetchUsername();
    _fetchSites();
    _fetchPrebuiltPackages();
    _fetchPublicCustomPackages();
    _loadRecommendations();
  }

  void _setGreetingMessage() {
    final currentHour = DateTime
        .now()
        .hour;
    if (currentHour < 12) {
      greetingMessage = "Good morning";
    } else if (currentHour < 17) {
      greetingMessage = "Good afternoon";
    } else {
      greetingMessage = "Good evening";
    }
  }

  Future<void> _fetchUsername() async {
    try {
      final userRef = FirebaseDatabase.instance.ref().child('Users').child(
          widget.userKey);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          username = userData['username'];
        });
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
  }

  Future<void> _fetchSites() async {
    try {
      final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('AttractionSites').child('Muscat');
      final snapshot = await attractionRef.once();

      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          _sites = data.entries
              .where((entry) => entry.value is Map) // Ensure only maps are processed
              .map((entry) {
            final siteData = Map<String, dynamic>.from(entry.value);

            return AttractionSite(
              siteName: siteData['siteName'] ?? 'Unknown Site', // Default to 'Unknown Site'
              category: siteData['category'] ?? 'Unknown Category', // Default value
              siteImage: siteData['siteImage'] ?? '', // Empty string if missing
              rating: (siteData['rating'] as num?)?.toDouble() ?? 0.0, // Default rating
              latitude: (siteData['latitude'] as num?)?.toDouble() ?? 0.0, // Default latitude
              longitude: (siteData['longitude'] as num?)?.toDouble() ?? 0.0, // Default longitude
              description: siteData['description'] ?? 'No description available.', // Default
              state: siteData['state'] ?? 'Unknown State', // Default value
              key: entry.key, // Use the key as provided
            );
          }).toList();
          _isLoadingSites = false;
        });
      } else {
        setState(() {
          _errorMessage = "No attraction sites found.";
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching sites: $e";
        _isLoadingSites = false;
      });
    }
  }



  Future<void> _fetchPrebuiltPackages() async {
    try {
      final DatabaseReference packageRef = FirebaseDatabase.instance.ref()
          .child('PreBuiltPackages');
      final snapshot = await packageRef.once();
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        setState(() {
          _prebuiltPackages = data.entries.map((entry) {
            return {
              'key': entry.key,
              'packageName': entry.value['packageName'],
              'category': entry.value['category'],
              'packageImage': entry.value['packageImage'],
            };
          }).toList();
          _isLoadingPackages = false;
        });
      } else {
        setState(() {
          _isLoadingPackages = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching packages: $e";
        _isLoadingPackages = false;
      });
    }
  }

  void _fetchPublicCustomPackages() {
    final customPackagesRef = FirebaseDatabase.instance.ref().child(
        'CustomPackages');
    customPackagesRef.onValue.listen((event) async {
      List<Map<String, dynamic>> publicPackages = [];
      if (event.snapshot.value is Map) {
        final data = event.snapshot.value as Map;
        for (var userEntry in data.entries) {
          final userId = userEntry.key;
          final userPackages = userEntry.value;

          if (userPackages is Map) {
            final userSnapshot = await FirebaseDatabase.instance.ref().child(
                'Users').child(userId).get();
            final creatorUsername = userSnapshot
                .child('username')
                .value ?? 'Unknown User';

            userPackages.forEach((packageId, package) {
              if (package['isPublic'] == true) {
                publicPackages.add({
                  'packageId': packageId,
                  'packageName': package['packageName'],
                  'creatorUsername': creatorUsername,
                  'attractions': package['attractions'] ?? [],
                });
              }
            });
          }
        }
      }

      setState(() {
        _publicCustomPackages = publicPackages;
        _isLoadingCustomPackages = false;
      });
    });
  }

  void _checkRecommendations(String category) {
    _categoryClicks[category] = (_categoryClicks[category] ?? 0) + 1;

    if (_categoryClicks[category]! > 3) {
      final recommendedSites = _sites.where((site) => site.category == category)
          .toList();
      _saveRecommendations(recommendedSites);
      setState(() {
        _recommendedSites = recommendedSites;
      });
    }
  }

  Future<void> _saveRecommendations(
      List<AttractionSite> recommendedSites) async {
    try {
      final recommendationsRef = FirebaseDatabase.instance.ref()
          .child('Users')
          .child(widget.userKey)
          .child('recommendations');
      await recommendationsRef.set({
        'recommendedSites': recommendedSites.map((site) => site.toJson())
            .toList(),
      });
    } catch (e) {
      print("Error saving recommendations: $e");
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendationsRef = FirebaseDatabase.instance.ref()
          .child('Users')
          .child(widget.userKey)
          .child('recommendations');
      final snapshot = await recommendationsRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final List<dynamic> recommendedSitesData = data['recommendedSites'] ??
            [];

        setState(() {
          _recommendedSites = recommendedSitesData
              .asMap()
              .entries
              .map((entry) {
            // Pass the entry's key as a string along with the map data
            return AttractionSite.fromJson(
                Map<String, dynamic>.from(entry.value), entry.key.toString());
          }).toList();
        });
      }
    } catch (e) {
      print("Error loading recommendations: $e");
    }
  }


  Widget _buildSectionTitle(
      {required String title, VoidCallback? onViewAllPressed}) {
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
        if (onViewAllPressed != null)
          TextButton(
            onPressed: onViewAllPressed,
            child: const Text(
              'See All',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }

  Widget _buildAttractionSites() {
    if (_isLoadingSites) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    } else if (_sites.isEmpty) {
      return const Center(child: Text("No attraction sites available."));
    } else {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _sites.length,
          itemBuilder: (context, index) {
            final site = _sites[index];
            return _buildAttractionCard(site, context);
          },
        ),
      );
    }
  }

  Widget _buildAttractionCard(AttractionSite site, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _checkRecommendations(site.category);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserSiteDetailsPage(
                  site: site,
                  userKey: widget.userKey,
                ),
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

  Widget _buildRecommendedSites() {
    if (_recommendedSites.isEmpty) {
      return const Center(child: Text("No recommendations available."));
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recommendedSites.length,
        itemBuilder: (context, index) {
          final site = _recommendedSites[index];
          return _buildAttractionCard(site, context);
        },
      ),
    );
  }

  Widget _buildPrebuiltPackages() {
    if (_isLoadingPackages) {
      return const Center(child: CircularProgressIndicator());
    } else if (_prebuiltPackages.isEmpty) {
      return const Center(child: Text("No pre-built packages available."));
    } else {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _prebuiltPackages.length,
          itemBuilder: (context, index) {
            final package = _prebuiltPackages[index];
            return _buildPackageCard(package, context);
          },
        ),
      );
    }
  }

  Widget _buildPublicCustomPackages() {
    if (_isLoadingCustomPackages) {
      return const Center(child: CircularProgressIndicator());
    } else if (_publicCustomPackages.isEmpty) {
      return const Center(child: Text("No public custom packages available."));
    } else {
      return SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _publicCustomPackages.length,
          itemBuilder: (context, index) {
            final package = _publicCustomPackages[index];
            return _buildPublicPackageCard(package, context);
          },
        ),
      );
    }
  }

  Widget _buildPackageCard(Map<String, dynamic> package, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PreBuiltPackageDetailsUserPage(
                  packageKey: package['key'],
                ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPublicPackageCard(Map<String, dynamic> package,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PublicCustomPackageDetailsPage(
                  package: package,
                  userKey: widget.userKey,
                ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package['packageName'] ?? 'Unnamed Package',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                'Created by: ${package['creatorUsername']}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "$greetingMessage, ${username ?? ''}!",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow
                            .ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(6, 6), //
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.auto_awesome, color: Colors.white),
                            tooltip: "Package Creator",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PackageCreatorPage(userKey: widget.userKey),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),


                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(
                  title: 'Attraction Sites',
                  onViewAllPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllUserAttractionSitesPage(
                              sites: _sites,
                              userKey: widget.userKey,
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildAttractionSites(),
                const SizedBox(height: 30),
                _buildSectionTitle(title: 'Pre-built Packages'),
                const SizedBox(height: 10),
                _buildPrebuiltPackages(),
                const SizedBox(height: 30),
                _buildSectionTitle(title: 'Public Custom Packages'),
                const SizedBox(height: 10),
                _buildPublicCustomPackages(),
                const SizedBox(height: 30),
                _buildSectionTitle(title: 'Recommended for You'),
                const SizedBox(height: 10),
                _buildRecommendedSites(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}