import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/group_chat_room.dart';
import 'package:flutterwhatsapp/pages/chats_tab.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutterwhatsapp/general_providers.dart';

class GroupChatHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.chat),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Chats(),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            context.read(firestoreProvider).collection('groups').snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
                child: Container(
              height: 50,
              width: 50,
              child: Center(
                child: Text(
                  "Something went Wrong!",
                ),
              ),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Container(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
          }

          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final user = context.read(authControllerProvider);
              final isUserinMemberslist = data['members']
                  .map((data) => data['number'])
                  .contains(user.phoneNumber);

              if (isUserinMemberslist) {
                return ListTile(
                  onTap: () async {
                    if (isUserinMemberslist) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoom(
                            memberslist: data['members'],
                            message: data['message'],
                            groupName: data['groupname'],
                            groupChatId: document.id,
                          ),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(msg: "You're not in this group");
                    }
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    backgroundImage: AssetImage("fonts/appiconkk.png"),
                  ),
                  title: Text(data['groupname']),
                  subtitle: Text(data['grpdetail']),
                  trailing: Icon(
                    Icons.chat,
                    color: Colors.red,
                  ),
                );
              } else {
                return Container();
              }
            }).toList(),
          );
        },
      ),
    );
  }
}
