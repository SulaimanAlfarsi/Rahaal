// lib/screens/enter_otp_page.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

import 'package:trip/screens/ResetPasswordPage.dart';

class EnterOTPPage extends StatefulWidget {
  final String email;
  String otp; // Change to non-final to allow updating OTP

  EnterOTPPage({required this.email, required this.otp});

  @override
  _EnterOTPPageState createState() => _EnterOTPPageState();
}

class _EnterOTPPageState extends State<EnterOTPPage> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Timer? _timer;
  int _remainingTime = 60;
  bool _isOTPExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _isOTPExpired = true;
        });
        _timer?.cancel();
      }
    });
  }

  Future<void> _sendOTPEmail(String email, String otp) async {
    // Replace with your email and password, or use environment variables
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

  void _resendOTP() async {
    setState(() {
      _remainingTime = 60;
      _isOTPExpired = false;
      _startTimer();
    });
    String newOTP = _generateOTP();
    widget.otp = newOTP; // Update the OTP in the widget
    await _sendOTPEmail(widget.email, newOTP);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('A new OTP has been sent to your email'), backgroundColor: Colors.green),
    );
  }

  void _verifyOTP() {
    if (_formKey.currentState!.validate()) {
      String enteredOTP = _otpControllers.map((controller) => controller.text).join();
      if (_isOTPExpired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The OTP has expired'), backgroundColor: Colors.red),
        );
      } else if (enteredOTP == widget.otp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 3) {
            FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
          } else if (value.length == 0 && index > 0) {
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
      ),
    );
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
                    'Enter OTP',
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
            // OTP Form
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
                          Image.asset('assets/6.0.png', height: 200),
                          SizedBox(height: 20),
                          // OTP Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => _buildOTPBox(index)),
                          ),
                          SizedBox(height: 20),
                          // Verify OTP Button
                          ElevatedButton(
                            onPressed: _verifyOTP,
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE07518)),
                            child: Text('Verify OTP', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 20),
                          // OTP Timer
                          Text(
                            'OTP expires in: $_remainingTime seconds',
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 20),
                          // Resend OTP Button
                          if (_isOTPExpired)
                            ElevatedButton(
                              onPressed: _resendOTP,
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2C3E50)),
                              child: Text('Resend OTP', style: TextStyle(color: Colors.white)),
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
