// lib/screens/signup_page.dart
import 'package:flutter/material.dart';
import '../Models/UsersModel.dart';
import 'loginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _attemptSignUp() async {
    if (_formKey.currentState!.validate()) {
      // Check if username or email already exist
      if (await Users.usernameExists(username.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Username already exists."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (await Users.emailExists(email.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email already exists."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Proceed with registration if validations pass
      String? result = await Users.signUpUser(
        username.text,
        email.text,
        password.text,
        role: "user",
      );

      if (result == null) {
        // Clear the input fields after successful registration
        username.clear();
        email.clear();
        password.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration successful!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register: $result"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                          Image.asset('assets/6.0.png', height: 80),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: username,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => Users.validateName(value),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => Users.validateEmail(value),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: password,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) => Users.validatePassword(value),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _attemptSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFE07518),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                            child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Login()),
                              );
                            },
                            child: Text(
                              'Already Have an Account? Login Now!',
                              style: TextStyle(color: Color(0xFF2C3E50)),
                            ),
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
