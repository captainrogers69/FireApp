import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/call_screen.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
import 'package:flutterwhatsapp/pages/login.dart';
import 'package:flutterwhatsapp/pages/status_screen.dart';

class WhatsAppHome extends StatefulWidget {
  // const WhatsAppHome({ Key key }) : super(key: key);

  @override
  _WhatsAppHomeState createState() => _WhatsAppHomeState();
}

class _WhatsAppHomeState extends State<WhatsAppHome>
    with SingleTickerProviderStateMixin {

  // final User user;
  // WhatsAppHome({this.user});
  TabController _tabController;
  bool showFab = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 1, length: 3);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        showFab = true;
      } else {
        showFab = false;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("FireApp"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(
              text: "CHATS",
            ),
            Tab(
              text: "GROUPS",
            ),
            Tab(
              text: "CALLS",
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.group_add,
            ),
          ),
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
                                    onPressed: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
          ChatScreen(),
          // Text("${user.phoneNumber}"),
          StatusScreen(),
          CallsScreen(),
        ],
      ),
    );
  }
}
  