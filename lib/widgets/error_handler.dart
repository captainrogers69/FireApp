import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  //error dialogs
  static Future<dynamic> errorDialog(BuildContext context, e) {
    return showCupertinoDialog(
        context: (context),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text('Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                      child: Text(e.message.toString()),
                    ),
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('okay'))
                      ],
                    ),
                  )
                ],
              ));
        });
  }
}
