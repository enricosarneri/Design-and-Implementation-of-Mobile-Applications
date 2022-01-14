import 'package:event_handler/main.dart';
import 'package:event_handler/models/event.dart';
import 'package:event_handler/screens/authenticate/registration.dart';
import 'package:event_handler/screens/home/pages/create_event.dart';
import 'package:event_handler/screens/home/side_filter.dart';
import 'package:event_handler/screens/home/pages/profile.dart';
import 'package:event_handler/screens/home/pages/share_link.dart';
import 'package:event_handler/screens/widget.dart/panel_widget.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:event_handler/screens/home/pages/google_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  final panelController = PanelController();
  int index = 0;
  double panelPosition = 200;
  Event event = Event('', '', '', 0, 0, '', '', '', 0, 0, '', [], [], [], 0);
  final screens = [
    GoogleMapScreen(),
    Share_Link(),
    Create_Event(),
    Profile(),
  ];

  void setSlidingUpPanel(newEvent) {
    setState(() {
      event = newEvent;
      panelController.panelPosition = 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    screens[0] = GoogleMapScreen(setSlidingUpPanelFuncion: setSlidingUpPanel);
    return Scaffold(
        extendBody: true,
        body: SlidingUpPanel(
            controller: panelController,
            parallaxEnabled: true,
            parallaxOffset: .5,
            minHeight: 0,
            maxHeight: MediaQuery.of(context).size.height,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            panelBuilder: (controller) => PanelWidget(
                  controller: controller,
                  panelController: panelController,
                  event: event,
                ),
            body: Scaffold(
              extendBody: true,
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
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
                  ),
                ),
              ),
              body: screens[index],
            )));
  }
}
