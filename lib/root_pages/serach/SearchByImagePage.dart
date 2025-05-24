import 'package:flutter/material.dart';

class SearchByImagePage extends StatelessWidget {
  const SearchByImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search by Image')),
      body: Center(
        child: Text(
          'Search for Attraction Sites by Image functionality will go here.',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
