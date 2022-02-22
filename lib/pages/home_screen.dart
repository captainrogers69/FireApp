import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
import 'package:flutterwhatsapp/pages/chats_tab.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isloading = false;
  final TextEditingController _search = TextEditingController();
  Map<String, dynamic> userMap;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_search.value.text.isNotEmpty) {
      setState(() {
        isloading = true;
      });

      await _firestore
          .collection('users')
          // .where("isAdmin", isNotEqualTo: true)
          .where("number", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = (value).docs[0].data();
          isloading = false;
        });
      }).onError((error, stackTrace) {
        Fluttertoast.showToast(msg: "Incorrect Phone Number");
        setState(() {
          isloading = false;
        });
      });
    } else {
      Fluttertoast.showToast(msg: "Enter a Number");
    }
  }

  void onSearch2() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["isAdmin"]) {
      onSearch();
    } else {
      Fluttertoast.showToast(msg: "Only Admin can Search users");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.chat),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Chats(),
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
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        child: TextField(
                          controller: _search,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Search Users",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.redAccent, //0xffF14C37
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        onPressed: onSearch2,
                        child: Text(
                          "Search User",
                        ),
                      ),
                      userMap != null
                          ? ListTile(
                              onTap: () async {
                                final checkExists = await _firestore
                                    .collection('chatroom')
                                    .where(
                                      "sender",
                                      isEqualTo: userMap["number"],
                                    )
                                    .where("reciever",
                                        isEqualTo:
                                            _auth.currentUser.phoneNumber)
                                    .get();

                                final checkExists2 = await _firestore
                                    .collection('chatroom')
                                    .where("reciever",
                                        isEqualTo: userMap['number'])
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
                                        chatRoomName: userMap['number'],
                                        sender: _auth.currentUser.phoneNumber,
                                        sendername:
                                            _auth.currentUser.displayName,
                                        reciever: userMap['number'],
                                        recieverName: userMap['name'],
                                      ),
                                    ),
                                  );
                                } else if (checkExists2.docs.isNotEmpty) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoom(
                                        chatRoomId: checkExists2.docs[0].id,
                                        chatRoomName: userMap['number'],
                                        sender: _auth.currentUser.phoneNumber,
                                        sendername:
                                            _auth.currentUser.displayName,
                                        reciever: userMap['number'],
                                        recieverName: userMap['name'],
                                      ),
                                    ),
                                  );
                                } else {
                                  final roomId = Uuid().v1();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoom(
                                        chatRoomId: roomId,
                                        chatRoomName: userMap['number'],
                                        sender: _auth.currentUser.phoneNumber,
                                        sendername:
                                            _auth.currentUser.displayName,
                                        reciever: userMap['number'],
                                        recieverName: userMap['name'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.red,
                                backgroundImage:
                                    AssetImage("fonts/appiconkk.png"),
                              ),
                              title: Text(userMap['name']),
                              subtitle: Text(userMap['number']),
                              trailing: Icon(
                                Icons.chat,
                                color: Colors.red,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )),
      ),
    );
  }
}
