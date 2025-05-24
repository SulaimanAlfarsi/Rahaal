import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/root_pages/settingpages/UserDetailsPageBookmarks.dart';
import 'package:trip/root_pages/userhome/seedetails.dart';

class FavoritePage extends StatefulWidget {
  final String userKey;

  const FavoritePage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late DatabaseReference bookmarksRef;
  List<AttractionSite> bookmarkedSites = [];
  bool isLoading = true;

  get userKey => null;

  @override
  void initState() {
    super.initState();
    bookmarksRef = FirebaseDatabase.instance
        .ref('Users')
        .child(widget.userKey)
        .child('bookmarks');

    _listenToBookmarks();
  }

  void _listenToBookmarks() {
    bookmarksRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final bookmarks = Map<dynamic, dynamic>.from(data as Map);
        setState(() {
          bookmarkedSites = bookmarks.entries.map((entry) {
            return AttractionSite.fromJson(
              Map<String, dynamic>.from(entry.value),
              entry.key,
            );
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          bookmarkedSites = [];
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        automaticallyImplyLeading: true,
        title: const Text('Favorites'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookmarkedSites.isEmpty
          ? const Center(child: Text('No bookmarked sites found.'))
          : ListView.builder(
        itemCount: bookmarkedSites.length,
        itemBuilder: (context, index) {
          final site = bookmarkedSites[index];
          return ListTile(
            leading: Image.network(
              site.siteImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(site.siteName),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeBookmark(site.key),
            ),
            onTap: () => _navigateToSiteDetails(site),
          );
        },
      ),
    );
  }


  void _navigateToSiteDetails(AttractionSite site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsPageBookmarks (
          site: site,
          userKey: userKey,
        ),
      ),
    );
  }

  // Remove a bookmark and show a red snackbar
  Future<void> _removeBookmark(String siteKey) async {
    await bookmarksRef.child(siteKey).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
