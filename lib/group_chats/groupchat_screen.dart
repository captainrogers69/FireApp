import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/group_chats/create%20group/add_members.dart';
import 'package:flutterwhatsapp/group_chats/group_chat_room.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutterwhatsapp/general_providers.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ), 
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Groups Available"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: context
            .read(firestoreProvider)
            .collection('groups')
            // .doc()
            // .collection('grouptag')
            .snapshots(),
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
              return ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GroupChatRoom(
                      message: data['message'],
                groupName: data['groupname'],
                groupChatId: document.id,
                ),
                ),
                ),
                leading: Icon(
                  Icons.verified_user,
                ),
                title: Text(data['groupname']),
                subtitle: Text(data['grpdetail']),
                trailing: Icon(
                  Icons.chat,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
