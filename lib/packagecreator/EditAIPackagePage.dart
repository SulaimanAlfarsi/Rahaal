import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'MyAIPackagesPage.dart';
import 'packagecreator.dart'; // Import the PackageCreatorPage

class EditAIPackagePage extends StatefulWidget {
  final String userKey;
  final String packageKey; // Package key to identify the package to update
  final String packageName;
  final List<Map<String, dynamic>> attractions;
  final List<String> categories;
  final double minRating;

  const EditAIPackagePage({
    Key? key,
    required this.userKey,
    required this.packageKey,
    required this.packageName,
    required this.attractions,
    required this.categories,
    required this.minRating,
  }) : super(key: key);

  @override
  State<EditAIPackagePage> createState() => _EditAIPackagePageState();
}

class _EditAIPackagePageState extends State<EditAIPackagePage> {
  late List<Map<String, dynamic>> _editableAttractions;
  final DatabaseReference _aiPackagesRef =
  FirebaseDatabase.instance.ref().child('AIPackages');

  @override
  void initState() {
    super.initState();
    _editableAttractions = List<Map<String, dynamic>>.from(widget.attractions);
  }

  void _removeSite(int index) {
    if (_editableAttractions.length > 2) {
      setState(() {
        _editableAttractions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete! A package must have at least 2 sites.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reorderSites(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final site = _editableAttractions.removeAt(oldIndex);
      _editableAttractions.insert(newIndex, site);
    });
  }

  Future<void> _saveUpdatedPackage() async {
    try {
      final packageRef = _aiPackagesRef.child(widget.packageKey);

      await packageRef.update({
        'updatedAt': DateTime.now().toIso8601String(),
        'attractions': _editableAttractions,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Package updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to PackageCreatorPage and replace current page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PackageCreatorPage(userKey: widget.userKey),
        ),
      );
    } catch (e) {
      print('Error updating package: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update package.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.packageName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              onReorder: _reorderSites,
              itemCount: _editableAttractions.length,
              itemBuilder: (context, index) {
                final site = _editableAttractions[index];
                return Card(
                  key: ValueKey(index),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeSite(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _saveUpdatedPackage,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
