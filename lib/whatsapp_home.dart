import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/create%20group/add_members.dart';
import 'package:flutterwhatsapp/pages/home_screen.dart';
import 'package:flutterwhatsapp/pages/user_admin.dart';
import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/login.dart';
import 'package:flutterwhatsapp/pages/user.dart';

class WhatsAppHome extends StatefulWidget {
  @override
  State<WhatsAppHome> createState() => _WhatsAppHomeState();
}

class _WhatsAppHomeState extends State<WhatsAppHome>
    with SingleTickerProviderStateMixin {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TabController _tabController;
// User user;
// DocumentSnapshot<Map<String, dynamic>> userFromUsersCollection;

  void createGroupByAdminOnly() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["authorization"]) {
      // onSearch();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddMembersInGroup(),
      ));
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Perform this Action");
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: 1,
      length: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final _tabController = useTabController(
    //   initialIndex: 1,
    //   initialLength: 3,
    // );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("KiyaKonnect"),
          automaticallyImplyLeading: false,
          elevation: 0.7,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              Tab(
                text: "ADMIN",
              ),
              Tab(
                text: "HOME",
              ),
              Tab(
                text: "SETTINGS",
              ),
            ],
          ),
          actions: <Widget>[
            // IconButton(
            //   onPressed: () {},
            //   icon: Icon(
            //     Icons.search,
            //   ),
            // ),
            SizedBox(
                child: IconButton(
              onPressed: createGroupByAdminOnly,
              icon: Icon(
                Icons.create,
              ),
            )),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                  "Log Out Confirm ?",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await context
                                            .read(authenticationServiceProvider)
                                            .signOut();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage()));
                                      },
                                      child: Text("Log Out"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            UserAdmin(),
            HomeScreen(),
            UserScreen(),
          ],
        ),
      ),
    );
  }

//   Widget creategroup(BuildContext context) async {
//   final user = context.read(authControllerProvider);
//     final userFromUsersCollection = await _firestore.collection('users').doc(user.uid).get();
//     if ( userFromUsersCollection.data()["authorization"] ) {
//    return
//    IconButton(
//                 onPressed: () => Navigator.of(context).push(     // only admin
//                   MaterialPageRoute(
//                     builder: (_) => AddMembersInGroup(),
//                   ),
//                 ),
//                 icon: Icon(
//                   Icons.create,
//                 ),
//             );
//             } else {

//       Fluttertoast.showToast(msg: "Only Admin can Perform this Action");
//     }
// }
}
