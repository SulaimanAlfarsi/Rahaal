import 'package:flutter/material.dart';
import 'package:trip/screens/LoginPage.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  @override
  Widget build(BuildContext context) {
    void _confirmLogout(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Logout', style: TextStyle(color: Colors.red)),
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



    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 16),
          Expanded(child:ListView(
            children: [
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),)
        ],
      )
    );
  }
}
