import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add_ic_call,),
        ),
      body: new Center(
        child: new Text(
          "Starting Calling Here",
          style: new TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
