import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/group_chats/create%20group/create_group.dart';

class AddMembersinNewGroup extends StatefulWidget {
  final String myToken;
  const AddMembersinNewGroup({Key key, @required this.myToken})
      : super(key: key);

  @override
  State<AddMembersinNewGroup> createState() => _AddMembersinNewGroupState();
}

class _AddMembersinNewGroupState extends State<AddMembersinNewGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic> userMap;
  // String thisUserFromFS = "";

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection('users')
        .where("number", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
    }).onError((error, stackTrace) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void onResultTap() {
    setState(() {
      membersList.add({
        "name": userMap['name'] != "" ? userMap['name'] : "unknown",
        "number": userMap['number'],
        "token": userMap['token'],
      });

      userMap = null;
    });
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  // void thisUser() async {}

  @override
  void initState() {
    setState(() {
      membersList.add({
        "name": _auth.currentUser.displayName != ""
            ? _auth.currentUser.displayName
            : _auth.currentUser.displayName != null
                ? "unknown"
                : "unknown",
        "number": _auth.currentUser.phoneNumber,
        "uid": _auth.currentUser.uid,
        "token": widget.myToken,
      });

      userMap = null;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Search Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      backgroundImage: AssetImage("fonts/appiconkk.png"),
                    ),
                    title: Text(membersList[index]['number']),
                    subtitle: Text(membersList[index]['name']),
                    trailing: Icon(Icons.close),
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Search",
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
            isLoading
                ? Container(
                    height: size.height / 12,
                    width: size.height / 12,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: onSearch,
                    child: Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onResultTap,
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      backgroundImage: AssetImage("fonts/appiconkk.png"),
                    ),
                    title: Text(userMap['number']),
                    subtitle: Text("Tap to select this Contact"),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox(),
          ],
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.forward),
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ));
              })
          : SizedBox(),
    );
  }
}
