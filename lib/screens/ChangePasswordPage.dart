// lib/screens/change_password_page.dart
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../Models/UsersModel.dart';

class ChangePasswordPage extends StatefulWidget {
  final String userKey;

  ChangePasswordPage({required this.userKey});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _sendSuccessEmail(String email) async {
    final String senderEmail = "sulaimanalfarsi3060@gmail.com";
    final String senderPassword = "zlpv fklf cbul idqc";

    final smtpServer = gmail(senderEmail, senderPassword);

    final message = Message()
      ..from = Address(senderEmail, 'Trip')
      ..recipients.add(email)
      ..subject = 'Password Changed Successfully'
      ..text =
          'Your password has been changed successfully. If you did not initiate this change, please contact support immediately.';

    try {
      await send(message, smtpServer);
    } catch (e) {
      print('Failed to send confirmation email: $e');
    }
  }

  void _changePassword(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String currentPassword = currentPasswordController.text;
      String newPassword = newPasswordController.text;

      try {
        // Fetch the latest stored password from Firebase
        final userRef = FirebaseDatabase.instance.ref().child('Users').child(widget.userKey);
        final snapshot = await userRef.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          String storedHashedPassword = userData['password'];

          // Authenticate with the latest password
          bool isAuthenticated = BCrypt.checkpw(currentPassword, storedHashedPassword);

          if (isAuthenticated) {
            // Validate the new password
            String? passwordValidationResult = Users.validatePassword(newPassword);
            if (passwordValidationResult != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(passwordValidationResult),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Update password using userKey
            String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
            await userRef.update({'password': hashedNewPassword});

            // Send confirmation email
            String? email = userData['email'];
            if (email != null) {
              await _sendSuccessEmail(email);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password changed successfully. A confirmation email has been sent.'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Current password is incorrect'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User data could not be retrieved'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/5.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: currentPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Current Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) => Users.validatePassword(value),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm the new password';
                              }
                              if (value != newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _changePassword(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE07518)),
                            child: Text('Change Password',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
