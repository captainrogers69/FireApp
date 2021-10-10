import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/widgets/user_edit_bottom_sheet.dart';
import 'package:flutterwhatsapp/widgets/user_page_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider);

    return Container(
      color: Color(0xff181c18),
      child: Center(
        child: ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            UserPageWidget(
              text: authControllerState.phoneNumber,
              actionWidget: IconButton(
                icon: Icon(
                  Icons.phone,
                  color: Color(0xff00cd7b),
                ),
                onPressed: () {},
              ),
            ),
            UserPageWidget(
              text: authControllerState.displayName,
              actionWidget: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Color(0xff00cd7b),
                ),
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25)),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      context: context,
                      builder: (BuildContext buildContext) {
                        return UserEditBottomSheet();
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
