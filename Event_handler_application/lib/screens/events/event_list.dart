import 'package:event_handler/models/event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventList extends StatefulWidget {

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {

    final events= Provider.of<List<Event>> (context);
    print(events);
    return Container(
      
    );
  }
}