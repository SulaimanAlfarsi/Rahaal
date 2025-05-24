import 'package:firebase_database/firebase_database.dart';

class AttractionSite {
  final String government; // Default to 'Muscat'
  final String state;
  final String siteName;
  final String category;
  final String siteImage; // Image URL
  final String description;
  final double latitude; // For Google Maps
  final double longitude; // For Google Maps
  final double rating; // Default 0.0
  final String key; // Firebase key

  AttractionSite({
    this.government = 'Muscat',
    required this.state,
    required this.siteName,
    required this.category,
    required this.siteImage,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    required this.key,
  });

  // Convert to JSON for Firebase storage
  Map<String, dynamic> toJson() => {
    'government': government,
    'state': state,
    'siteName': siteName,
    'category': category,
    'siteImage': siteImage,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'rating': rating,
  };

  // Firebase reference
  static final DatabaseReference _attractionRef =
  FirebaseDatabase.instance.ref().child('AttractionSites');

  // Add a new attraction site
  static Future<String?> addAttractionSite(AttractionSite site) async {
    bool isDuplicate = await checkDuplicateSite(site.siteName);
    if (isDuplicate) return 'Site name already exists';

    await _attractionRef.child(site.government).push().set(site.toJson());
    return null; // Success
  }

  // Check for duplicate sites by name
  static Future<bool> checkDuplicateSite(String siteName) async {
    String normalizedSiteName = normalizeString(siteName);
    final snapshot = await _attractionRef
        .child('Muscat')
        .orderByChild('siteName')
        .equalTo(normalizedSiteName)
        .once();
    return snapshot.snapshot.value != null;
  }

  // Normalize string (lowercase, trim spaces)
  static String normalizeString(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Update an attraction site
  static Future<void> updateAttractionSite(
      String siteKey, AttractionSite site) async {
    await _attractionRef
        .child(site.government)
        .child(siteKey)
        .update(site.toJson());
  }

  // Delete an attraction site
  static Future<void> deleteAttractionSite(String siteKey) async {
    await _attractionRef.child('Muscat').child(siteKey).remove();
  }

  // Get all attraction sites under 'Muscat'
  static Future<List<AttractionSite>> getAttractionSites() async {
    final snapshot = await _attractionRef.child('Muscat').once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      return data.entries
          .map((entry) =>
          AttractionSite.fromJson(Map<String, dynamic>.from(entry.value), entry.key))
          .toList();
    }
    return [];
  }

  // Create an AttractionSite object from JSON
  factory AttractionSite.fromJson(Map<dynamic, dynamic> json, String key) {
    return AttractionSite(
      key: key,
      government: json['government'] ?? 'Muscat',
      state: json['state'],
      siteName: json['siteName'],
      category: json['category'],
      siteImage: json['siteImage'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }
}
