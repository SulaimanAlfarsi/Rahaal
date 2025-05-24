import 'package:flutter/material.dart';
import 'package:trip/admin/admin_screens/Add.dart';
import 'package:trip/admin/admin_screens/addpages/package.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavigationButton(
              context: context,
              title: 'Add Attraction Site',
              icon: Icons.place,
              color: Colors.blueAccent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAttractionSitePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            _buildNavigationButton(
              context: context,
              title: 'Add Pre-built Packages',
              icon: Icons.card_travel,
              color: Colors.greenAccent.shade700,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPrebuiltPackagesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget method to build navigation buttons
  Widget _buildNavigationButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: color,
        elevation: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
