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
          left: isSideBarOpenedAsync.data!
              ? 0
              : -(screenWidth - (screenWidth * 0.75)),
          right: isSideBarOpenedAsync.data!
              ? screenWidth - (screenWidth * 0.75)
              : screenWidth - 20,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  width: screenWidth * 0.75,
                  height: 270,
                  color: Color(0xFFf1f5fb),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    onIconPressed();
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Container(
                        width: 20,
                        height: 270,
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: buildIcon(context, isSideBarOpenedAsync.data!)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildIcon(BuildContext context, bool isCollapsed) {
    final icon = isCollapsed
        ? Icons.keyboard_arrow_left_rounded
        : Icons.keyboard_arrow_right_rounded;
    return Container(
      width: 20,
      color: Color(0xFFf1f5fb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Icon(
          icon,
          color: Colors.black87,
          size: 20,
        ),
      ),
    );
  }
}
