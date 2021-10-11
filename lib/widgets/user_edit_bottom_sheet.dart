import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserEditBottomSheet extends HookWidget {
  const UserEditBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final _usernameController = useTextEditingController();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        width: size.width,
        height: size.height / 1.5,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              Icons.drag_handle,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Container(
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "current Name",
                    helperText: 'What should we call you?',
                    helperStyle: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: MaterialButton(
                color: Colors.lightBlue,
                child: Text("Update"),
                onPressed: () async {
                  await context
                      .read(authenticationServiceProvider)
                      .setDisplayName(_usernameController.text);

                  _usernameController.text = "";
                  Navigator.of(context).pop();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
