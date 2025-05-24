import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../trips.dart';

class EditCustomPackagePage extends StatefulWidget {
  final Map<String, dynamic> package;
  final String userId;

  const EditCustomPackagePage({
    Key? key,
    required this.package,
    required this.userId,
  }) : super(key: key);

  @override
  _EditCustomPackagePageState createState() => _EditCustomPackagePageState();
}

class _EditCustomPackagePageState extends State<EditCustomPackagePage> {
  List<Map<String, dynamic>> _attractions = [];
  bool _isSaving = false;
  bool _isPublic = false;

  @override
  void initState() {
    super.initState();
    _attractions = List<Map<String, dynamic>>.from(widget.package['attractions']);
    _isPublic = widget.package['isPublic'] ?? false; // Initialize with current status
  }

  void _deleteAttraction(int index) {
    if (_attractions.length > 2) { // Only allow deletion if more than 2 attractions
      setState(() {
        _attractions.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A package must contain at least 2 attractions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _savePackage() async {
    setState(() => _isSaving = true);

    final packageRef = FirebaseDatabase.instance
        .ref()
        .child('CustomPackages')
        .child(widget.userId)
        .child(widget.package['key']);

    await packageRef.update({
      'attractions': _attractions,
      'isPublic': _isPublic,
    });

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package updated successfully!'),backgroundColor: Colors.green,),
    );

    Navigator.pop(context, true); // Indicate successful save
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.package['packageName']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePackage,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Reorder or delete attractions in your custom package. Press "Save" to confirm changes.',
              textAlign: TextAlign.center,
            ),
          ),
          SwitchListTile(
            title: const Text('Make Package Public'),
            value: _isPublic,
            onChanged: (value) {
              setState(() {
                _isPublic = value;
              });
            },
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                setState(() {
                  final attraction = _attractions.removeAt(oldIndex);
                  _attractions.insert(newIndex, attraction);
                });
              },
              children: List.generate(_attractions.length, (index) {
                final attraction = _attractions[index];
                return ListTile(
                  key: ValueKey(attraction['siteName']),
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_handle),
                      const SizedBox(width: 8),
                      Image.network(
                        attraction['siteImage'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                  title: Text(attraction['siteName'] ?? 'Unknown'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAttraction(index),
                  ),
                );
              }),
            ),
          ),
          if (_isSaving) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
