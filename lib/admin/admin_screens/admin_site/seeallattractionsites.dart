import 'package:flutter/material.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/admin/admin_screens/admin_site/site_details_page.dart';

class AllAttractionSitesPage extends StatelessWidget {
  final List<AttractionSite> sites;

  const AllAttractionSitesPage({Key? key, required this.sites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('All Attraction Sites'),
      ),
      body: sites.isEmpty
          ? Center(child: const Text('No attraction sites available.')) // Empty state message
          : ListView.builder(
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
                  builder: (context) => SiteDetailsPage(
                    site: site,          // Pass the selected site
                    siteKey: site.key,   // Pass the Firebase key
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
