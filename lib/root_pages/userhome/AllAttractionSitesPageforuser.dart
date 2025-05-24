import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/root_pages/userhome/seedetails.dart';

class AllUserAttractionSitesPage extends StatelessWidget {
  final List<AttractionSite> sites;
  final String userKey; // Add userKey

  const AllUserAttractionSitesPage({
    Key? key,
    required this.sites,
    required this.userKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attraction Sites'),
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (context, index) {
          final site = sites[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(site.siteImage),
              radius: 25,
            ),
            title: Text(site.siteName),
            subtitle: Text(site.state),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserSiteDetailsPage(
                    site: site,
                    userKey: userKey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
