// lib/screens/reset_password_page.dart
import 'package:flutter/material.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:trip/Models/UsersModel.dart';
import 'package:trip/screens/LoginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  ResetPasswordPage({required this.email});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _sendSuccessEmail(String email) async {
    // Replace with your email and password, or use environment variables
    final String senderEmail = "sulaimanalfarsi3060@gmail.com";
    final String senderPassword = "zlpv fklf cbul idqc";

    final smtpServer = gmail(senderEmail, senderPassword);

    final message = Message()
      ..from = Address(senderEmail, 'trip')
      ..recipients.add(email)
      ..subject = 'Password Changed Successfully'
      ..text = 'Your password has been changed successfully. If you did not initiate this change, please contact support immediately.';

    try {
      await send(message, smtpServer);
      // Optionally, you can show a success message here
    } catch (e) {
      // Handle email sending error if needed
      print('Failed to send confirmation email: $e');
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final newPassword = _passwordController.text;

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

      try {
        bool success = await Users.updatePasswordByEmail(widget.email, newPassword);
        if (success) {
          await _sendSuccessEmail(widget.email); // Send confirmation email

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password reset successful. A confirmation email has been sent.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reset password'),
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Your existing Scaffold code...
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
            // Top Bar
            Padding(
              padding: EdgeInsets.only(left: 16, top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  // Title
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),
            // Form
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
                          Image.asset('assets/6.0.png', height: 100),
                          SizedBox(height: 20),
                          // New Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => Users.validatePassword(value),
                          ),
                          SizedBox(height: 20),
                          // Confirm New Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Reset Password Button
                          ElevatedButton(
                            onPressed: _resetPassword,
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE07518)),
                            child: Text('Reset Password', style: TextStyle(color: Colors.white)),
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
