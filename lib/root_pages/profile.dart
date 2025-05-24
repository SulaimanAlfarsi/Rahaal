// lib/screens/ProfilePage.dart
import 'package:flutter/material.dart';
import 'package:trip/Account/AccountDetailsPage.dart';
import 'package:trip/root_pages/profilepages/AboutPage.dart';
import 'package:trip/root_pages/profilepages/HelpAndSupportPage.dart';
import 'package:trip/root_pages/profilepages/privacy.dart';
import 'package:trip/root_pages/settingpages/bookmark.dart';
import 'package:trip/screens/ChangePasswordPage.dart';
import 'package:trip/screens/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  final String userKey; // Add userKey parameter

  const ProfilePage({Key? key, required this.userKey}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(
          userKey: widget.userKey,
        ),
      ),
    );
  }

  void _navigateToAccountDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailsPage(
          userKey: widget.userKey,
        ),
      ),
    );
  }

  void _navigateToBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePage(
          userKey: widget.userKey,
        ),
      ),
    );
  }

  void _navigateToPrivacySecurityPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrivacySecurityPage(),
      ),
    );
  }

  void _navigateToAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AboutPage(),
      ),
    );
  }
  void _navigateToHelpAndSupportPage () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpAndSupportPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Account'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToAccountDetails,
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Current Password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToChangePassword,
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Attraction Sites Bookmarks'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToBookmarks,
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy & Security'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToPrivacySecurityPage,
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help and Support'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToHelpAndSupportPage,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _navigateToAboutPage,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
