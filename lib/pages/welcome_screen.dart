import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: Text(
                "Welcome to Kiya Konnect",
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 20, 15, 20),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 180,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(35, 20, 35, 20),
              child: Column(
                children: [
                  Text(
                    "Tap Agree and Continue to accept",
                    style: TextStyle(
                      // fontSize: 22,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "the Terms of Service and Privacy Policy",
                    style: TextStyle(
                      // fontSize: 22,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 15, 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthChecker(),
                    ),
                  );
                },
                child: Text("Agree and Continue"),
              ),
            )
          ],
        ),
      )),
    );
  }
}
