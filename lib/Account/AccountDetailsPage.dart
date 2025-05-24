// lib/screens/Account.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/Account/editprofile.dart';

class AccountDetailsPage extends StatefulWidget {
  final String userKey; // Use userKey instead of username

  const AccountDetailsPage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    // Use the userKey directly to access the user data
    final userRef = FirebaseDatabase.instance
        .ref()
        .child('Users')
        .child(widget.userKey); // Access by userKey

    final snapshot = await userRef.get();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        username = userData['username'];
        email = userData['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with Profile Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Account Details',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // User Details Card
              username != null && email != null
                  ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username Row
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            username!,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1),

                      // Email Row
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 28,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            email!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),

              const Spacer(),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(userKey: widget.userKey), // Pass userKey
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.orange,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
