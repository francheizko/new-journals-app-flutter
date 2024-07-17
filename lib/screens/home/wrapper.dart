import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:state_change_demo/constants/constants.dart';
import 'package:state_change_demo/screens/home/googlemap_screen.dart';
import 'package:state_change_demo/screens/home/home_screen.dart';
import 'package:state_change_demo/screens/home/profile_screen.dart';
import '../../routing/router.dart';

class HomeWrapper extends StatefulWidget {
  final Widget? child;
  const HomeWrapper({super.key, this.child});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int index = 0;

  List<String> routes = [
    HomeScreen.route,
    MapScreen.route,
    ProfileScreen.route
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child ?? const Placeholder(),
      bottomNavigationBar: BottomNavigationBar(
        unselectedIconTheme: const IconThemeData(color: lsecfontcolor),
        selectedIconTheme: const IconThemeData(color: ldarkblue),
        selectedLabelStyle: GoogleFonts.poppins(color: ldarkblue),
        unselectedLabelStyle: GoogleFonts.poppins(color: lsecfontcolor),
        backgroundColor: lwhite,
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;
            GlobalRouter.I.router.go(routes[i]);
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "About",
          ),
        ],
      ),
    );
  }
}
