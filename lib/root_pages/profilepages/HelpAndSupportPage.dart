import 'package:flutter/material.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({Key? key}) : super(key: key);

  @override
  _HelpAndSupportPageState createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Need Assistance?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We’re here to help you make the most out of Rahaal! Whether you have questions, need guidance, or are facing issues, you’ll find answers here or can contact us directly.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Support'),
              subtitle: const Text('Sulaiman.rahaal@gmail.com'),
              onTap: () {
                // Handle email action
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Support'),
              subtitle: const Text('+968 92004175'),
              onTap: () {
                // Handle phone call action
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'FAQs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('How do I reset my password?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'To reset your password, go to the login page and click on "Forgot Password." Enter your registered email, and we will send you an OTP to reset your password securely.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How do I make my package private?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'When creating or editing a package, toggle the privacy option to private. Only you will be able to see this package.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('What do I do if an attraction site is missing?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'If you notice an attraction site is missing, please reach out to us through email support with the site details, and we’ll work on adding it.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Troubleshooting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Ensure you have a stable internet connection for optimal app performance.\n'
                  '• Restart the app if it crashes or behaves unexpectedly.\n'
                  '• Clear the app cache if you experience loading issues in the settings.\n'
                  '• Update to the latest version of Rahaal for new features and bug fixes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: const Text(
                'Thank you for using Rahaal!',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
