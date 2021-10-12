import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';
// import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({
    @required this.membersList,
    Key key,
  }) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = _auth.currentUser.uid;

    await _firestore.collection('groups').doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
    });

    // for (int i = 0; i < widget.membersList.length; i++) {
    // String uid = widget.membersList[i]['uid'];

    // await _firestore
    //     .collection('users')
    //     .doc(uid)
    //     .collection('groups')
    //     .doc(groupId)
    //     .update({
    //   "grpname": _groupName.text,
    //   "id": groupId,
    // });
    // }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "groupname": _groupName.text,
      "grpdetail": " created by ${_auth.currentUser.displayName}",
      "message": "${_auth.currentUser.displayName} Created This Group.",
      "type": "notification",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => WhatsAppHome()), (route) => false);

    await Fluttertoast.showToast(msg: "Group Created Now");
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Group Name"),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _groupName,
                      decoration: InputDecoration(
                        hintText: "Enter Group Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: createGroup,
                  child: Text("Create Group"),
                ),
              ],
            ),
    );
  }
}
