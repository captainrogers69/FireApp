
import 'package:flutter/material.dart';

Widget aAppLoading() {
  return Container(
    color: Colors.white,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

//Navigator Push
Future aPushTo(BuildContext context, Widget widget) {
  return Navigator.push(context,
        MaterialPageRoute(builder: (context) => widget));
}

//Navigator PushReplacement
Future aPushReplace(BuildContext context, Widget widget) {
  return Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => widget));
}