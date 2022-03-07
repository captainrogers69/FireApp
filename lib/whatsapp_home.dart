import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/create%20group/add_members.dart';
import 'package:flutterwhatsapp/group_chats/groupchat_screen.dart';
import 'package:flutterwhatsapp/main.dart';
import 'package:flutterwhatsapp/pages/home_screen.dart';
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
  bool thisUserAdmin = false;

  void createGroupByAdminOnly() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["isAdmin"]) {
      // onSearch();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => AddMembersinNewGroup(),
      ));
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Perform this Action");
    }
  }

  // Future<void> isThisUserAdmin() async {
  //   final user = context.read(authControllerProvider);
  //   final userFromUsersCollection =
  //       await _firestore.collection('users').doc(user.uid).get();
  //   if (userFromUsersCollection.data()["isAdmin"]) {
  //     setState(() {
  //       thisUserAdmin = true;
  //     });
  //   } else {
  //     setState(() {
  //       thisUserAdmin = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      vsync: this,
      initialIndex: 0,
      length: 3,
    );

    void tokenFromDevice() async {
      final token = await FirebaseMessaging.instance.getToken();

      print(token);
    }

    tokenFromDevice();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                // channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        RemoteNotification notification = message.notification;
        AndroidNotification android = message.notification?.android;
        if (notification != null && android != null) {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text(notification.title),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(notification.body)],
                    ),
                  ),
                );
              });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(
            "KiyaKonnect",
            style: TextStyle(
                fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          elevation: 0.7,
          bottom: TabBar(
              // indicator: BoxDecoration(
              //     borderRadius: BorderRadius.circular(100), // Creates border
              //     color: Colors.redAccent),
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  text: "GROUPS",
                ),
                Tab(
                  text: "ADMIN",
                ),
                Tab(
                  text: "SETTINGS",
                ),
              ]),
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
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red),
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
                  },
                );
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
            GroupChatHomeScreen(),
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
//     if ( userFromUsersCollection.data()["isAdmin"] ) {
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
