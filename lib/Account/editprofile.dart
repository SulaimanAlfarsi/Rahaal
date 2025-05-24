// lib/screens/EditProfilePage.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditProfilePage extends StatefulWidget {
  final String userKey;

  const EditProfilePage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final userRef = FirebaseDatabase.instance.ref().child('Users').child(widget.userKey);
    final snapshot = await userRef.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _usernameController.text = userData['username'];
        _emailController.text = userData['email'].toString().toLowerCase(); // Ensure initial email is lowercase
      });
    }
  }

  Future<bool> _isDuplicateUsernameOrEmail(String username, String email) async {
    final ref = FirebaseDatabase.instance.ref().child('Users');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

      for (var key in users.keys) {
        if (key != widget.userKey) { // Skip the current user
          Map<dynamic, dynamic> user = users[key];
          if (user['username'] == username) {
            _showErrorSnackBar('Username already exists');
            return true;
          }
          if (user['email'].toString().toLowerCase() == email.toLowerCase()) { // Case-insensitive check
            _showErrorSnackBar('Email already exists');
            return true;
          }
        }
      }
    }
    return false;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) return "Username cannot be empty";
    if (name.length < 4) return "Invalid username, must be at least 4 characters";
    if (RegExp(r'^\d+$').hasMatch(name)) return "Username cannot be only numbers";
    if (!RegExp(r'[A-Za-z]').hasMatch(name)) {
      return "Username must contain at least one letter";
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(name)) {
      return "Username can only contain letters and numbers";
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return "Email cannot be empty";
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return "Invalid Email";
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String newUsername = _usernameController.text.trim();
    String newEmail = _emailController.text.trim().toLowerCase(); // Normalize email to lowercase

    setState(() {
      _isLoading = true;
    });

    bool hasDuplicate = await _isDuplicateUsernameOrEmail(newUsername, newEmail);
    if (hasDuplicate) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final ref = FirebaseDatabase.instance.ref().child('Users').child(widget.userKey);
    await ref.update({
      'username': newUsername,
      'email': newEmail,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context); // Go back to the previous page

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: validateName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
