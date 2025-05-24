import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:trip/screens/EnterOTPPage.dart';
import 'dart:math';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseReference mydb = FirebaseDatabase.instance.ref().child('Users');

  Future<void> _sendOTPEmail(String email, String otp) async {
    final String senderEmail = "sulaimanalfarsi3060@gmail.com";
    final String senderPassword = "zlpv fklf cbul idqc";

    final smtpServer = gmail(senderEmail, senderPassword);

    final message = Message()
      ..from = Address(senderEmail, 'trip')
      ..recipients.add(email)
      ..subject = 'Password Reset'
      ..text = 'Your password reset code is: $otp';

    try {
      await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset code sent to your email.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _generateOTP() {
    final random = Random();
    int otp = 1000 + random.nextInt(9000); // Generates a random 4-digit number
    return otp.toString();
  }

  Future<void> _checkEmailAndSendOTP() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.toLowerCase();

      final snapshot = await mydb.orderByChild('email').equalTo(email).once();
      if (snapshot.snapshot.value != null) {
        String otp = _generateOTP();
        await _sendOTPEmail(email, otp);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterOTPPage(email: email, otp: otp),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Forgot Password',
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
                          Image.asset('assets/6.0.png', height: 80),
                          SizedBox(height: 20),
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.black),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          // Send OTP Button
                          ElevatedButton(
                            onPressed: _checkEmailAndSendOTP,
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE07518)),
                            child: Text('Send OTP to Email', style: TextStyle(color: Colors.white)),
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
