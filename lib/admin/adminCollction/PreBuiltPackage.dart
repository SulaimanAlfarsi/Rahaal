// lib/Models/PreBuiltPackage.dart
import 'package:firebase_database/firebase_database.dart';

class PreBuiltPackage {
  final String packageName;
  final String category;
  final String visibility;
  final List<Map<String, dynamic>> attractions; // List of attractions
  final String packageImage; // Package image URL
  final String key; // Firebase key


  PreBuiltPackage({
    required this.packageName,
    required this.category,
    required this.visibility,
    required this.attractions,
    required this.packageImage,
    required this.key,
  });

  // Convert to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'category': category,
      'visibility': visibility,
      'attractions': attractions.map((site) => site).toList(),
      'packageImage': packageImage, // Include package image URL
    };
  }

  // Firebase reference
  static final DatabaseReference _packagesRef =
  FirebaseDatabase.instance.ref().child('PreBuiltPackages');

  // Add a new PreBuilt Package to the database
  static Future<void> addPackage(PreBuiltPackage package) async {
    await _packagesRef.push().set(package.toJson());
  }

  // Update an existing package
  static Future<void> updatePackage(String key, PreBuiltPackage package) async {
    await _packagesRef.child(key).update(package.toJson());
  }

  // Delete a package from Firebase
  static Future<void> deletePackage(String key) async {
    await _packagesRef.child(key).remove();
  }

  // Create PreBuiltPackage object from JSON
  factory PreBuiltPackage.fromJson(Map<dynamic, dynamic> json, String key) {
    return PreBuiltPackage(
      packageName: json['packageName'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      visibility: json['visibility'] ?? 'public',
      attractions: List<Map<String, dynamic>>.from(json['attractions'] ?? []),
      packageImage: json['packageImage'] ?? '',
      key: key,
    );
  }
}
