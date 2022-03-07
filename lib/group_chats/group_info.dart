import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/edit_members.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
import 'package:uuid/uuid.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  final List groupMembers;
  const GroupInfo({
    @required this.groupId,
    @required this.groupName,
    @required this.groupMembers,
    Key key,
  }) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    membersList = widget.groupMembers;
  }

  addingmemberstogrouprules() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["isAdmin"]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMembersINGroup(
              name: widget.groupName,
              membersList: membersList,
              groupChatId: widget.groupId),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Add Members to the Group");
    }
  }

  //leaving group

  void leavegroupcheckingadmin() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["isAdmin"]) {
      Fluttertoast.showToast(msg: "Administrators can't Leave this Group");
    } else {
      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': widget.groupMembers
            .where((member) => member['number'] != user.phoneNumber)
            .toList()
      });
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "You Left the Group");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Group Info"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              height: size.height / 8,
              width: size.width / 1.1,
              child: Row(
                children: [
                  Container(
                    height: size.height / 11,
                    width: size.height / 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage("fonts/appiconkk.png"),
                    ),
                  ),
                  SizedBox(
                    width: size.width / 20,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        widget.groupName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: size.width / 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // members length
            Container(
              width: size.width / 1.1,
              child: Text(
                "${widget.groupMembers.length} Members",
                style: TextStyle(
                  fontSize: size.width / 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10
                // size.height / 20,
                ),

            ListTile(
              onTap: addingmemberstogrouprules,
              leading: Icon(
                Icons.add_circle,
                color: Colors.red,
              ),
              title: Text(
                "Add Members",
                style: TextStyle(
                  fontSize: size.width / 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                  itemCount: widget.groupMembers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onLongPress: () async {
                        final user = context.read(authControllerProvider);
                        final userFromUsersCollection = await _firestore
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        if (userFromUsersCollection.data()["isAdmin"]) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                        backgroundImage:
                                            AssetImage("fonts/appiconkk.png")),
                                    title: Text(
                                        widget.groupMembers[index]['number']),
                                    subtitle: Text(
                                        widget.groupMembers[index]['name']),
                                    // trailing: Icon(Icons.edit),
                                  )
                                ],
                              );
                            },
                          );
                        }
                      },
                      onTap: () async {
                        final user = context.read(authControllerProvider);
                        final userFromUsersCollection = await _firestore
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        if (userFromUsersCollection.data()["isAdmin"]) {
                          if (widget.groupMembers[index]['number'] !=
                              _auth.currentUser.phoneNumber) {
                            final checkExists = await _firestore
                                .collection('chatroom')
                                .where(
                                  "sender",
                                  isEqualTo: widget.groupMembers[index]
                                      ['number'],
                                )
                                .where("reciever",
                                    isEqualTo: _auth.currentUser.phoneNumber)
                                .get();

                            final checkExists2 = await _firestore
                                .collection('chatroom')
                                .where("reciever",
                                    isEqualTo: widget.groupMembers[index]
                                        ['name'])
                                .where(
                                  "sender",
                                  isEqualTo: _auth.currentUser.phoneNumber,
                                )
                                .get();

                            if (checkExists.docs.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoom(
                                    chatRoomId: checkExists.docs[0].id,
                                    chatRoomName: widget.groupMembers[index]
                                        ['number'],
                                    sender: _auth.currentUser.phoneNumber,
                                    sendername: _auth.currentUser.displayName,
                                    reciever: widget.groupMembers[index]
                                        ['number'],
                                    recieverName: widget.groupMembers[index]
                                        ['name'],
                                  ),
                                ),
                              );
                            } else if (checkExists2.docs.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoom(
                                    chatRoomId: checkExists2.docs[0].id,
                                    chatRoomName: widget.groupMembers[index]
                                        ['number'],
                                    sender: _auth.currentUser.phoneNumber,
                                    sendername: _auth.currentUser.displayName,
                                    reciever: widget.groupMembers[index]
                                        ['number'],
                                    recieverName: widget.groupMembers[index]
                                        ['name'],
                                  ),
                                ),
                              );
                            } else {
                              final roomId = Uuid().v1();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoom(
                                    chatRoomId: roomId,
                                    chatRoomName: widget.groupMembers[index]
                                        ['number'],
                                    sender: _auth.currentUser.phoneNumber,
                                    sendername: _auth.currentUser.displayName,
                                    reciever: widget.groupMembers[index]
                                        ['number'],
                                    recieverName: widget.groupMembers[index]
                                        ['name'],
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Not Authorised");
                        }
                      },
                      leading: CircleAvatar(
                        backgroundImage: AssetImage("fonts/appiconkk.png"),
                      ),
                      title: Text(widget.groupMembers[index]['number'] ==
                              _auth.currentUser.phoneNumber
                          ? "Me"
                          : widget.groupMembers[index]['name']),
                      // subtitle: Text(
                      //   widget.groupMembers[index]['isAdmin'],
                      // ),
                      trailing: Icon(
                        Icons.chat,
                        color: Colors.red,
                      ),
                    );
                  }),
            ),
            ListTile(
              onTap: leavegroupcheckingadmin,
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                "Leave Group",
                style: TextStyle(
                  fontSize: size.width / 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
