import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/group_chats/create%20group/add_members.dart';
import 'package:flutterwhatsapp/group_chats/group_chat_room.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key key}) : super(key: key);

  @override
  _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser.uid;

    await _firestore
        .collection('groups')
        .doc(uid)
        .collection('chats')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Groups"),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupChatRoom(
                  groupName: groupList[index]['groupname'],
                  groupChatId: groupList[index]['id'],
                  ),
                  ),
                  ),
                  leading: Icon(Icons.group),
                  title: Text(groupList[index]['groupname']),
                  subtitle: Text(groupList[index]['type']),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddMembersInGroup(),
          ),
        ),
        tooltip: "Create Group",
      ),
    );
  }
}



// class GroupChatHomeScreen extends StatefulWidget {
//   const GroupChatHomeScreen({Key key}) : super(key: key);

//   @override
//   _GroupChatHomeScreenState createState() => _GroupChatHomeScreenState();
// }

// class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     // final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Groups",
//         ),
//       ),
//       body: ListView.builder(
//           itemCount: 5,
//           itemBuilder: (context, index) {
//             return ListTile(
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => GroupChatRoom()));
//               },
//               leading: Icon(
//                 Icons.group,
//               ),
//               title: Text(
//                 "Group $index",
//               ),
//             );
//           }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         child: Icon(
//           Icons.create,
//         ),
//       ),
//     );
//   }
// }
