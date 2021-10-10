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
    return Container(
      width: size.width,
      height: size.height / 1.5,
      decoration: BoxDecoration(
        color: Color(0xffc2fbe1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Container(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  helperText: 'What should we call you?',
                  helperStyle: TextStyle(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(30),
            child: MaterialButton(
              color: Color(0xff00cd7b),
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
    );
  }
}
