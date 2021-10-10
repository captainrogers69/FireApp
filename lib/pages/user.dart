import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: [
            Text("User Info Here",),
            Text("Like name, number, status",),
            Text("Name Feature Here",),
          ],
        ),
      ),
    );
  }
}