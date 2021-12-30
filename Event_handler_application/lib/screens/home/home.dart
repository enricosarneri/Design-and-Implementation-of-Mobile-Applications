import 'package:event_handler/main.dart';
import 'package:event_handler/screens/authenticate/registration.dart';
import 'package:event_handler/screens/home/pages/create_event.dart';
import 'package:event_handler/screens/home/side_filter.dart';
import 'package:event_handler/screens/home/pages/profile.dart';
import 'package:event_handler/screens/home/pages/share_link.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:event_handler/screens/home/pages/google_map_screen.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  int index = 0;
  final screens = [
    GoogleMapScreen(),
    Share_Link(),
    Create_Event(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: screens[index],
        extendBody: true,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 5,
            //     blurRadius: 7,
            //     offset: Offset(0, 3),
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Colors.blue.shade100,
                labelTextStyle: MaterialStateProperty.all(
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              child: NavigationBar(
                height: 60,
                backgroundColor: Color(0xFFf1f5fb),
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: index,
                animationDuration: Duration(seconds: 1),
                onDestinationSelected: (index) =>
                    setState(() => this.index = index),
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.location_on_outlined,
                      size: 25,
                    ),
                    selectedIcon: Icon(
                      Icons.location_on,
                      size: 25,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.share_outlined,
                      size: 25,
                    ),
                    selectedIcon: Icon(
                      Icons.share_sharp,
                      size: 25,
                    ),
                    label: 'Share Link',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.add_box_outlined,
                      size: 25,
                    ),
                    selectedIcon: Icon(
                      Icons.add_box,
                      size: 25,
                    ),
                    label: 'Create Event',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outlined,
                      size: 25,
                    ),
                    selectedIcon: Icon(
                      Icons.person,
                      size: 25,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
              // appBar: AppBar(
              //   title: Text('Event handler'),
              //   backgroundColor: Colors.brown[400],
              //   elevation: 0.0,
              //   actions: <Widget>[
              //     TextButton.icon(
              //         onPressed: () async {
              //           await _authService.signOut();
              //           //to be changed
              //         },
              //         icon: const Icon(Icons.person),
              //         label: const Text('Logout'))
              //   ],
              // ),
            ),
          ),
        ),
      );
}

@override
Widget ShareLink(BuildContext context) {
  return Expanded(
    child: Center(
      child: Text(
        "Link",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
