import 'package:flutter/material.dart';
import 'package:trip/screens/loginPage.dart';
import 'package:trip/screens/signupPage.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/5.png"),
            fit: BoxFit.cover,
            opacity: 0.7),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 65, horizontal: 25),
            child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Enjoy ",
                style: TextStyle(
                  color: Color(0xFFE07518) ,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text("Explore Oman!",
                  style: TextStyle(
                    color: Color(0xFF2C3E50) ,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  )),
              SizedBox(
                height: 12,
              ),
              Text(
                "Welcome to Rahaal App",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.9),
                    fontSize: 16,
                    letterSpacing: 1.2),
              ),
              SizedBox(
                height: 200,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                      );
                    },
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(),
                        ),
                      );
                    },
                    child: Text('Register'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFE07518) ,
                      disabledForegroundColor: Colors.grey.withOpacity(0.38), disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}