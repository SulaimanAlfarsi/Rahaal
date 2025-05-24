import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:trip/admin/admin_screens/Add.dart';
import 'package:trip/admin/admin_screens/addpages/addPage.dart';
import 'package:trip/admin/admin_screens/adminPprofile.dart';
import 'package:trip/admin/admin_screens/adminTrip.dart';
import 'package:trip/admin/admin_screens/admin_home.dart';
import 'package:trip/admin/admin_screens/manage_user.dart';

class Admin_root extends StatefulWidget {
  const Admin_root({super.key});

  @override
  State<Admin_root> createState() => _Admin_rootState();
}

class _Admin_rootState extends State<Admin_root> {

  int _bottomNavIndex = 0;
  late List<Widget> pages;


  @override
  void initState() {
    super.initState();
    pages = [
      AdminHomePage(),
      AdminTrip(),
      AddPage(),
      AdminProfile(),
    ];
  }

  List<IconData> iconList = [
    Icons.home_outlined,
    Icons.account_balance,
    Icons.add_circle_outline,
    Icons.account_circle_sharp,
  ];


  List<String> titleList = [
    'Home',
    'Trips',
    'Add',
    'Profile',
  ];


  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: ManageUsersPage(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        child: Image.asset(
          'assets/users.png',
          height: 30,
        ),
        backgroundColor: Color(0xFFE07518),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Colors.white,
        activeColor: Color(0xFFE07518),
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
