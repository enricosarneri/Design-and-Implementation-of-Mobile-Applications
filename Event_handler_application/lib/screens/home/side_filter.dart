import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SideFilter extends StatefulWidget {
  @override
  _SideFilterState createState() => _SideFilterState();
}

class _SideFilterState extends State<SideFilter>
    with SingleTickerProviderStateMixin<SideFilter> {
  AnimationController? _animationController;
  StreamController<bool>? isSideBarOpenedStreamController;
  Stream<bool>? isSideBarOpenedStream;
  StreamSink<bool>? isSideBarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSideBarOpenedStreamController = PublishSubject<bool>();
    isSideBarOpenedStream = isSideBarOpenedStreamController!.stream;
    isSideBarOpenedSink = isSideBarOpenedStreamController!.sink;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    isSideBarOpenedStreamController!.close();
    isSideBarOpenedSink!.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController!.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;
    if (isAnimationCompleted) {
      isSideBarOpenedSink!.add(false);
      _animationController!.reverse();
    } else {
      isSideBarOpenedSink!.add(true);
      _animationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSideBarOpenedStream,
      builder: (context, isSideBarOpenedAsync) {
        return AnimatedPositioned(
          duration: _animationDuration,
          top: 0,
          bottom: 0,
          left: isSideBarOpenedAsync.data! ? 0 : 0,
          right: isSideBarOpenedAsync.data!
              ? screenWidth - (screenWidth * 0.75)
              : screenWidth - 20,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: screenWidth * 0.75,
                  height: 250,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  onIconPressed();
                },
                child: Container(
                    width: 20,
                    height: 250,
                    color: Colors.amber,
                    alignment: Alignment.centerLeft,
                    child: AnimatedIcon(
                      progress: _animationController!.view,
                      icon: AnimatedIcons.menu_close,
                      color: Colors.black87,
                      size: 20,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
