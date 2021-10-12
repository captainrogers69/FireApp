import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // final Size size = MediaQuery.of(context).size;

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
              .doc(_auth.currentUser.uid)
              .collection('chats')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
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
                  groupChatId: data['id'],
                  ),
                  ),
                  ),
                  leading: Icon(Icons.verified_user,),
                  title: Text(data['groupname']),
                  subtitle: Text(data['grpdetail']),
                  trailing: Icon(Icons.chat,),
                );
              }).toList(),
            ); 
          },
        ));
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
