import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {@required this.name,
      @required this.membersList,
      @required this.groupChatId,
      Key key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
  }

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
    }); 
  }

  void onAddMembers() async {

     setState(() {
        membersList.add({
          "name": userMap['name'],
          "number": userMap['number'],
          "uid": userMap['uid'],
        });
        
        userMap = null;
      });

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
      
    });
    Fluttertoast.showToast(msg: "Member has been added to the group");
setState(()  {});
    
  }

void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Edit Members of "+ widget.name),
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
                    leading: Icon(Icons.account_circle),
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
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red
                  ),
                    onPressed: onSearch,
                    child: Text("Search"),
                  ),
            userMap != null
                ? ListTile(
                    onTap: onAddMembers,
                    leading: Icon(Icons.account_box),
                    title: Text(userMap['name']),
                    subtitle: Text(userMap['number']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
