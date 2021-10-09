import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/login.dart';

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(
          Icons.add_ic_call,
        ),
      ),
      body: Center(
        child: Text(
          "Starting Calling Here",
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
