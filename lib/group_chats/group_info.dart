import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/add_members.dart';
// import 'package:flutterwhatsapp/services/auth_service.dart';

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

  // @override
  // void initState() async {

  //   final data2 = await context
  //                   .read(firestoreProvider)
  //                   .collection('groups')
  //                   .get();

  //   setState(() {
  //     membersList = data2.docs.
  //   });
  //   super.initState();
  // }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // @override
  // void initState() {
  //   super.initState();
  //   getGroupDetails();
  // }

  // Future getGroupDetails() async {
  //   await _firestore.collection('groups').doc()
  // }

  // bool checkAdmin() {
  //   bool isAdmin = false;

  //   membersList.forEach((element) {
  //     if (element['uid'] == _auth.currentUser.uid) {
  //       isAdmin = element['isAdmin'];
  //     }
  //   });
  //   return isAdmin;
  // }

  // Future removeMembers(int index) async {
  //   String uid = membersList[index]['uid'];

  //   setState(() {
  //     isLoading = true;
  //     membersList.removeAt(index);
  //   });

  //   await _firestore.collection('groups').doc(widget.groupId).update({
  //     "members": membersList,
  //   }).then((value) async {
  //     await _firestore
  //         .collection('users')
  //         .doc(uid)
  //         .collection('groups')
  //         .doc(widget.groupId)
  //         .delete();

  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  // void showDialogBox(int index) {
  //   if (checkAdmin()) {
  //     if (_auth.currentUser.uid != membersList[index]['uid']) {
  //       showDialog(
  //           context: context,
  //           builder: (context) {
  //             return AlertDialog(
  //               content: ListTile(
  //                 onTap: () => removeMembers(index),
  //                 title: Text("Remove This Member"),
  //               ),
  //             );
  //           });
  //     }
  //   }
  // }

  // Future onLeaveGroup() async {
  //   if (!checkAdmin()) {
  //     setState(() {
  //       isLoading = true;
  //     });

  //     for (int i = 0; i < membersList.length; i++) {
  //       if (membersList[i]['uid'] == _auth.currentUser.uid) {
  //         membersList.removeAt(i);
  //       }
  //     }

  //     await _firestore.collection('groups').doc(widget.groupId).update({
  //       "members": membersList,
  //     });

  //     await _firestore
  //         .collection('users')
  //         .doc(_auth.currentUser.uid)
  //         .collection('groups')
  //         .doc(widget.groupId)
  //         .delete();

  //     Navigator.of(context).pushAndRemoveUntil(
  //       MaterialPageRoute(builder: (_) => WhatsAppHome()),
  //       (route) => false,
  //     );
  //   }
  // }

  //adding new members to the group

    addingmemberstogrouprules() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["authorization"]) {
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddMembersINGroup(
          groupChatId: widget.groupId,
          name: widget.groupName,
          membersList: membersList,
        ),
      ),
    );
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Perform this Action");
    }
  }

  //leaving group

  void leavegroupcheckingadmin() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["authorization"]) {
      Fluttertoast.showToast(msg: "You're an Admin, Can't Leave Group");
    } else {
      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': widget.groupMembers
            .where((member) => member['number'] != user.phoneNumber).toList()
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
        backgroundColor: Colors.lightBlue,
        title: Text("Group Info"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: size.height / 8,
              width: size.width / 1.1,
              child: Row(
                children: [
                  Container(
                    height: size.height / 11,
                    width: size.height / 11,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Icon(
                      Icons.group,
                      color: Colors.white,
                      size: size.width / 10,
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
            SizedBox(
              height: 10,
              // size.height / 20,
            ),
            //Add Members
            ListTile(
              onTap: addingmemberstogrouprules,
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                "Add Members",
                style: TextStyle(
                  fontSize: size.width / 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Flexible(
            //   child: ListView.builder(
            //     itemCount: membersList.length,
            //     shrinkWrap: true,
            //     physics: NeverScrollableScrollPhysics(),
            //     itemBuilder: (context, index) {
            //       return ListTile(
            //         // onTap: () => showDialogBox(index),
            //         leading: Icon(Icons.account_circle),
            //         title: Text(
            //           "mayank",
            //           // membersList[index]['name'],
            //           style: TextStyle(
            //             fontSize: size.width / 22,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //         subtitle: Text(membersList[index]['number']),
            //         trailing:
            //             Text(membersList[index]['isAdmin'] ? "Admin" : ""),
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.groupMembers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.person,
                      ),
                      title: Text(
                        widget.groupMembers[index]['name'],
                      ),
                      // subtitle: Text(
                      //   widget.groupMembers[index]['authorization'],
                      // ),
                      trailing: Icon(
                        Icons.chat,
                      ),
                    );
                  }),
            ),
            ListTile(
              onTap: leavegroupcheckingadmin,

              leading: Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: Text(
                "Leave Group",
                style: TextStyle(
                  fontSize: size.width / 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
