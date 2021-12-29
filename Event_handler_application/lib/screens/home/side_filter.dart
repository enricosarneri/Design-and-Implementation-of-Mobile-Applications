import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SideFilter extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final isCollapsed = false;

    return Container(
      height: 250,
      width: isCollapsed ? MediaQuery.of(context).size.width * 0.05 : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomRight: Radius.circular(20)),
          child: Drawer(
            child: Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                    child: buildHeader(isCollapsed),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(bool isCollapsed) => Row(
        children: [
          const SizedBox(
            width: 24,
          ),
          FlutterLogo(
            size: 24,
          ),
          const SizedBox(
            width: 16,
          ),
          Text(
            'Filters',
            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
            ),
          ),
        ],
      );
}
