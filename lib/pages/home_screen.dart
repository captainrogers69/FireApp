import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/group_chats/groupchat_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isloading = false;
  final TextEditingController _search = TextEditingController();
  Map<String, dynamic> userMap;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // String chatRoomId(String user1, user2) {
  //   if (user1[0].toLowerCase().codeUnits[0] >
  //       user2.toLowerCase().codeUnits[0]) {
  //     return "$user1$user2";
  //   } else {
  //     return "$user2$user1";
  //   }
  // }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isloading = true;
    });

    await _firestore
        .collection('users')
        .where("number", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = (value).docs[0].data();
        isloading = false;
      });
      print(userMap);
    });
  }

  void onSearch2() async {

    final user = context.read(authControllerProvider);
    final userFromUsersCollection = await _firestore.collection('users').doc(user.uid).get();
    if ( userFromUsersCollection.data()["authorization"] ) {
      onSearch();
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Perform this Action");
    }
  }

  void contactadminfeature() async {
     final user = context.read(authControllerProvider);
    final userFromUsersCollection = await _firestore.collection('users').doc(user.uid).get();
    if ( userFromUsersCollection.data()["authorization"] ) {
      Fluttertoast.showToast(msg: "You're an Administrator");
    } else {
      Fluttertoast.showToast(msg: "Admin will be right back to you!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: isloading
            ? Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListTile(
                      onTap: contactadminfeature,
                            // onTap: () {
                            //   String roomId = chatRoomId(
                            // _auth.currentUser.phoneNumber,
                            // userMap['status'],
                            // userMap['number'],
                            // );

                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //       builder: (_) => ChatRoom(
                            //         chatRoomId: roomId,
                            //         userMap: userMap,
                            //       ),
                            //     ),
                            //   );
                            // },
                            leading: Icon(Icons.verified_user, size: 25, color: Colors.redAccent,),
                            title: Text('Contact Admin'),
                            subtitle: Text("Tap here to chat"),
                            trailing: Icon(Icons.chat, color: Colors.redAccent,),
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _search,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Search Users(admin)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent
                    ),
                    onPressed: onSearch2,
                    child: Text(
                      "Search User",
                    ),
                  ),
                  userMap != null
                      ? ListTile(
                        onTap: () {
                          Fluttertoast.showToast(msg: "One on One chat Coming Soon");
                        },
                          // onTap: () {
                          //   String roomId = chatRoomId(
                          // _auth.currentUser.phoneNumber,
                          // userMap['status'],
                          // userMap['number'],
                          // );
      
                          //   Navigator.of(context).push(
                          //     MaterialPageRoute(
                          //       builder: (_) => ChatRoom(
                          //         chatRoomId: roomId,
                          //         userMap: userMap,
                          //       ),
                          //     ),
                          //   );
                          // },
                          leading: Icon(Icons.person, size: 30,),
                          title: Text(userMap['name']),
                          subtitle: Text("Tap here to Chat"),
                          trailing: Icon(Icons.chat),
                        )
                      : Container(),
                ],
              ),
      ),
      
    );
  }
}
