import 'package:flutter/material.dart';

class UserPageWidget extends StatelessWidget {
  const UserPageWidget({Key key, this.actionWidget, this.text})
      : super(key: key);

  final String text;
  final Widget actionWidget;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(
              10.0,
            ),
            child: Text(
              text ?? "Username",
              style: TextStyle(color: Colors.white),
            ),
          ),
          actionWidget,
        ],
      ),
    );
  }
}