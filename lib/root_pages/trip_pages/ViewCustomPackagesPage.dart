import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/root_pages/trip_pages/EditCustomPackagePage.dart';
import 'package:trip/root_pages/trip_pages/UserGoogleMapPageCustom.dart' as map_page;

class ViewCustomPackagesPage extends StatefulWidget {
  final String userId;

  const ViewCustomPackagesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewCustomPackagesPageState createState() => _ViewCustomPackagesPageState();
}

class _ViewCustomPackagesPageState extends State<ViewCustomPackagesPage> {
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    final packageRef = FirebaseDatabase.instance.ref().child('CustomPackages').child(widget.userId);
    final snapshot = await packageRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      setState(() {
        _packages = data.entries.map((entry) {
          final packageData = Map<String, dynamic>.from(entry.value as Map);
          return {
            'key': entry.key,
            'packageName': packageData['packageName'],
            'isPublic': packageData['isPublic'],
            'attractions': List<Map<String, dynamic>>.from(packageData['attractions'].map((attr) => Map<String, dynamic>.from(attr))),
          };
        }).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToEditPage(Map<String, dynamic> package) async {
    bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomPackagePage(package: package, userId: widget.userId),
      ),
    );

    if (isUpdated == true) {
      _fetchPackages();
    }
  }

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

  Future<void> _deletePackage(String packageKey) async {
    final packageRef = FirebaseDatabase.instance.ref().child('CustomPackages').child(widget.userId).child(packageKey);
    await packageRef.remove();
    setState(() {
      _packages.removeWhere((package) => package['key'] == packageKey);
    });
  }

  void _navigateToMap(List<Map<String, dynamic>> attractions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => map_page.UserGoogleMapPageCustom(attractions: attractions),
      ),
    );
  }

  void _sharePackage(Map<String, dynamic> package) async {
    if (package['isPublic'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only public packages can be shared.')),
      );
      return;
    }

    final shouldShare = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Package'),
          content: const Text('Are you sure you want to share this package in the community?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Share'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldShare == true) {
      final communityRef = FirebaseDatabase.instance.ref().child('CommunityMessages');
      await communityRef.push().set({
        'userKey': widget.userId,
        'packageName': package['packageName'],
        'packageDetails': package['attractions'],
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      Future.delayed(Duration(milliseconds: 100), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package successfully shared in the community!'), backgroundColor: Colors.green),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('My Custom Packages'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
          ? const Center(child: Text('No custom packages found.'))
          : ListView.builder(
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final package = _packages[index];
          final packageName = package['packageName'] ?? 'Unnamed Package';
          final isPublic = package['isPublic'] ?? false;
          final attractions = package['attractions'] ?? [];

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    packageName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(isPublic ? 'Public' : 'Private'),
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
                      if (isPublic)
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.purple),
                          onPressed: () => _sharePackage(package),
                          tooltip: 'Share Package',
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
                        final isStartPoint = i == 0;
                        final isEndPoint = i == attractions.length - 1;

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
                              if (isStartPoint)
                                const Text(
                                  'Start Point',
                                  style: TextStyle(color: Colors.green, fontSize: 12),
                                ),
                              if (isEndPoint && !isStartPoint)
                                const Text(
                                  'End Point',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
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
