import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/root_pages/userhome/googlemapuser.dart';

class UserSiteDetailsPage extends StatefulWidget {
  final AttractionSite site;
  final String userKey;
  final double? avgRating; // Optional avgRating from previous page

  const UserSiteDetailsPage({
    Key? key,
    required this.site,
    required this.userKey,
    this.avgRating,
  }) : super(key: key);

  @override
  _UserSiteDetailsPageState createState() => _UserSiteDetailsPageState();
}

class _UserSiteDetailsPageState extends State<UserSiteDetailsPage> {
  bool isBookmarked = false;
  late DatabaseReference userBookmarksRef;
  late DatabaseReference ratingsRef;
  late DatabaseReference siteRef;
  String? bookmarkKey;
  double avgRating = 0.0;
  bool hasUserRated = false;

  @override
  void initState() {
    super.initState();
    userBookmarksRef = FirebaseDatabase.instance
        .ref('Users')
        .child(widget.userKey)
        .child('bookmarks');
    ratingsRef = FirebaseDatabase.instance.ref('Ratings').child(widget.site.key);
    siteRef = FirebaseDatabase.instance
        .ref('AttractionSites')
        .child('Muscat')
        .child(widget.site.key);

    avgRating = widget.avgRating ?? 0.0; // Use passed avgRating if available
    checkIfBookmarked();
    if (widget.avgRating == null) {
      fetchAverageRating(); // Fetch avgRating only if not passed
    }
    checkIfUserRated();
  }

  Future<void> checkIfBookmarked() async {
    final snapshot = await userBookmarksRef
        .orderByChild('siteName')
        .equalTo(widget.site.siteName)
        .once();

    if (snapshot.snapshot.value != null) {
      final data = (snapshot.snapshot.value as Map).entries.first;
      setState(() {
        isBookmarked = true;
        bookmarkKey = data.key;
      });
    }
  }

  void toggleBookmark() {
    if (isBookmarked) {
      userBookmarksRef.child(bookmarkKey!).remove().then((_) {
        setState(() {
          isBookmarked = false;
          bookmarkKey = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark removed'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      final newBookmarkRef = userBookmarksRef.push();
      final bookmarkData = widget.site.toJson();

      newBookmarkRef.set(bookmarkData).then((_) {
        setState(() {
          isBookmarked = true;
          bookmarkKey = newBookmarkRef.key;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site bookmarked'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  Future<void> fetchAverageRating() async {
    final snapshot = await ratingsRef.once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map;
      double totalRating = 0.0;
      int ratingCount = 0;

      data.forEach((key, value) {
        if (value is Map && value.containsKey('rating')) {
          totalRating += (value['rating'] as num).toDouble();
          ratingCount++;
        }
      });

      setState(() {
        avgRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
      });

      await siteRef.update({'rating': avgRating});
    }
  }

  Future<void> checkIfUserRated() async {
    final snapshot = await ratingsRef.child(widget.userKey).get();
    setState(() {
      hasUserRated = snapshot.exists;
    });
  }

  Future<void> submitRating(double rating) async {
    if (!hasUserRated) {
      await ratingsRef.child(widget.userKey).set({
        'rating': rating,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      setState(() {
        hasUserRated = true;
      });
      await fetchAverageRating();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for rating!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already rated this site.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.site.siteName),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.favorite : Icons.favorite_border,
              color: isBookmarked ? Colors.red : Colors.grey,
            ),
            onPressed: toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.site.siteImage,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                widget.site.siteName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Rating: ',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                ],
              ),
              const SizedBox(height: 16),
              Text('Category: ${widget.site.category}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(widget.site.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserGoogleMapPage(
                        latitude: widget.site.latitude,
                        longitude: widget.site.longitude,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'View on Map',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              hasUserRated
                  ? Text(
                'You have already rated this site.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate this site:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.orange,
                    ),
                    onRatingUpdate: (rating) => submitRating(rating),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
