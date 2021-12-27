import 'package:event_handler/screens/events/create_event.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:event_handler/screens/home/google_map_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Event handler'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
              onPressed: () async {
                await _authService.signOut();
                //to be changed
              },
              icon: const Icon(Icons.person),
              label: const Text('Logout'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapScreen(),
          ),
        ),
        tooltip: 'GoogleMap',
        child: const Icon(Icons.pin_drop_outlined),
      ),
      // body: Container(
      //   alignment: Alignment.bottomLeft,
      //   padding: EdgeInsets.only(left: 15.0, bottom: 10.0),
      //   child: ElevatedButton(
      //     child: const Icon(Icons.add_location_alt_outlined),
      //     onPressed: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => Create_Event(),
      //       ),
      //     ),
      //   ),
      // ),
      body: Column(
        children: <Widget>[
          _index == 0
              ? ShareLink(context)
              : (_index == 1
                  ? ShareLink(context)
                  : _index == 2
                      ? Create_Event()
                      : ShareLink(context)),
          Padding(
            padding: EdgeInsets.only(
                top: 10.0,
                left: 18,
                right: 18,
                bottom: MediaQuery.of(context).padding.bottom),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _index == 0 ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.home,
                            color: _index == 0 ? Colors.white : Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _index == 0 ? "Home" : "",
                              style: TextStyle(
                                color:
                                    _index == 0 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _index == 1 ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.mobile_screen_share,
                            color: _index == 1 ? Colors.white : Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _index == 1 ? "Shake Link" : "",
                              style: TextStyle(
                                color:
                                    _index == 1 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = 2;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _index == 2 ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            color: _index == 2 ? Colors.white : Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _index == 2 ? "Create Event" : "",
                              style: TextStyle(
                                color:
                                    _index == 2 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = 3;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _index == 3 ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: _index == 3 ? Colors.white : Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              _index == 3 ? "Profile" : "",
                              style: TextStyle(
                                color:
                                    _index == 3 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
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
}
