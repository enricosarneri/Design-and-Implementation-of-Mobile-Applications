import 'package:flutter/material.dart';

class Share_Link extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.red,
          child: const Center(
            child: Text('Link'),
          ),
        ),
      ),
    );
  }
}
