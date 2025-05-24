import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:trip/root_pages/Home.dart';
import 'package:trip/root_pages/search.dart';
import 'package:trip/root_pages/profile.dart';
import 'package:trip/root_pages/trips.dart';
import 'package:trip/root_pages/CommunityPage.dart';

class RootPage extends StatefulWidget {
  final String userKey; // Add userKey parameter

  const RootPage({
    Key? key,
    required this.userKey, // Initialize userKey
  }) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(userKey: widget.userKey), // Pass userKey
      SearchPage(userKey: widget.userKey), // Pass userKey to Search
      CreateCustomPackagePage(userId: widget.userKey),
      ProfilePage(userKey: widget.userKey), // Pass userKey
    ];
  }

  List<IconData> iconList = [
    Icons.home_filled,
    Icons.search,
    Icons.place,
    Icons.settings,
  ];

  List<String> titleList = [
    'Home',
    'Search',
    'Trips',
    'Profile',
  ];

  @override
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
              child: CommunityPage(userKey: widget.userKey), // Pass userKey to CommunityPage
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        child: Image.asset(
          'assets/users.png',
          height: 30,
        ),
        backgroundColor: const Color(0xFFE07518),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Colors.white,
        activeColor: const Color(0xFFE07518),
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
