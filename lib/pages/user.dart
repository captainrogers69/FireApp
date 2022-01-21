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
      color: Colors.white,
      child: Center(
        child: ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            // Container(
            //   padding: EdgeInsets.only(top: 15, bottom: 15),
            //   child: Stack(
            //     alignment: Alignment.bottomCenter,
            //     children: [
            //       CircleAvatar(
            //         radius: 80,
            //         backgroundImage: NetworkImage(authControllerState
            //                 .photoURL ??
            //             "https://fanfest.com/wp-content/uploads/2021/02/Loki.jpg"),
            //       ),
            //       IconButton(
            //         onPressed: () {
            //           showModalBottomSheet(
            //               isDismissible: true,
            //               backgroundColor:
            //                   Theme.of(context).scaffoldBackgroundColor,
            //               shape: RoundedRectangleBorder(
            //                 borderRadius:
            //                     BorderRadius.vertical(top: Radius.circular(25)),
            //               ),
            //               clipBehavior: Clip.antiAliasWithSaveLayer,
            //               context: context,
            //               builder: (BuildContext buildContext) {
            //                 return UserProfileBottomSheet();
            //               });
            //         },
            //         icon: Icon(Icons.edit, color: Colors.white),
            //       ),
            //     ],
            //   ),
            // ),
            UserPageWidget(
              text: authControllerState.phoneNumber,
              actionWidget: IconButton(
                icon: Icon(
                  Icons.phone,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
            UserPageWidget(
              text: authControllerState.displayName,
              actionWidget: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      context: context,
                      builder: (BuildContext buildContext) {
                        return UserEditBottomSheet();
                      });
                },
              ),
            ),
            // UserPageWidget(
            //   text: "Logged In",
            //   actionWidget: IconButton(
            //     icon: Icon(
            //       Icons.logout,
            //       color: Colors.white,
            //     ),
            //     onPressed: () {
            //       showDialog(
            //           context: context,
            //           builder: (context) {
            //             return SimpleDialog(
            //               children: [
            //                 Container(
            //                   padding: EdgeInsets.all(20),
            //                   child: Column(
            //                     mainAxisAlignment:
            //                         MainAxisAlignment.spaceBetween,
            //                     children: [
            //                       Text(
            //                         "Log Out Confirm ?",
            //                         style: TextStyle(
            //                           fontSize: 20,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       ),
            //                       Row(
            //                         mainAxisAlignment:
            //                             MainAxisAlignment.spaceBetween,
            //                         children: [
            //                           TextButton(
            //                             onPressed: () {
            //                               Navigator.pop(context);
            //                             },
            //                             child: Text("Cancel"),
            //                           ),
            //                           ElevatedButton(
            //                             onPressed: () async {
            //                               await context
            //                                   .read(
            //                                       authenticationServiceProvider)
            //                                   .signOut();
            //                             },
            //                             child: Text("Log Out"),
            //                           ),
            //                         ],
            //                       )
            //                     ],
            //                   ),
            //                 ),
            //               ],
            //             );
            //           });
            //     },
            //   ),
            // ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(
            //     vertical: 8,
            //     horizontal: 30,
            //   ),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: Colors.lightBlue,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     width: MediaQuery.of(context).size.width,
            //     height: 50,
            //     child: Center(child: Text("User Logged In")),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
