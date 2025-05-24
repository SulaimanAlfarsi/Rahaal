import 'package:flutter/material.dart';

class AdminTrip extends StatefulWidget {
  const AdminTrip({super.key});

  @override
  State<AdminTrip> createState() => _AdminTripState();
}

class _AdminTripState extends State<AdminTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Admin Trip"
        ),
      ),
    );
  }
}
