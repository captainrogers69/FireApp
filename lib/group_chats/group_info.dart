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
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


@override
  void initState() {
    super.initState();
    membersList = widget.groupMembers;
  }


    addingmemberstogrouprules() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["authorization"]) {
      
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddMembersINGroup(
        name: widget.groupName, 
        membersList: membersList, 
        groupChatId: widget.groupId
        ),
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
    if (userFromUsersCollection.data()["authorization"]) {
      Fluttertoast.showToast(msg: "Administrators can't Leave this Group");
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
        backgroundColor: Colors.redAccent,
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
                      color: Colors.red,
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
                Icons.add_circle,
                      color: Colors.redAccent,
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
                      leading: Icon(
                        Icons.person,
                      color: Colors.redAccent,
                      ),
                      title: Text(
                        widget.groupMembers[index]['name'],
                      ),
                      // subtitle: Text(
                      //   widget.groupMembers[index]['authorization'],
                      // ),
                      trailing: Icon(
                        Icons.chat,
                      color: Colors.redAccent,
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
