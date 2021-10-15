import 'package:flutterwhatsapp/group_chats/groupchat_screen.dart';
import 'package:flutterwhatsapp/pages/home_screen.dart';
import 'package:flutterwhatsapp/pages/user_admin.dart';
import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterwhatsapp/pages/login.dart';
import 'package:flutterwhatsapp/pages/user.dart';

class WhatsAppHome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _tabController = useTabController(initialIndex: 1, initialLength: 3);

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
                text: "USERS",
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
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupChatHomeScreen(),
                ),
              ),
              icon: Icon(
                Icons.group,
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
}
