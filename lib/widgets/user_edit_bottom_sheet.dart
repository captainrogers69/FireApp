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
    final isLoading = useState(false);
    return Container(
      width: size.width,
      height: size.height / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: isLoading.value
          ? Center(
              child: Container(
                width: 85,
                height: 85,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Icon(Icons.drag_handle,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: Container(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        helperText: 'What should we call you?',
                        focusColor: Colors.red,
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Enter New Name",
                        helperStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                  child: MaterialButton(
                    color: Colors.red,
                    child: Text("Update"),
                    onPressed: () async {
                      isLoading.value = true;

                      await context
                          .read(authenticationServiceProvider)
                          .setDisplayName(_usernameController.text);

                      isLoading.value = false;

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