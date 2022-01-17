import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
import 'package:flutterwhatsapp/pages/chat_to_admin.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Chats extends StatefulWidget {
  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Map<String, dynamic> userMap;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool thisUserAdmin = false;
  List chatForAdmin = [];

  String chatRoomId(String user1, user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<void> isThisUserAdmin() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["authorization"]) {
      setState(() {
        thisUserAdmin = true;
      });
    } else {
      setState(() {
        thisUserAdmin = false;
      });
    }
  }

  Future<void> chatAuth() async {
    final user = context.read(authControllerProvider);
    final checkDocForSender = await _firestore
        .collection('chatroom')
        .where("sender", isEqualTo: user.phoneNumber)
        .get();
    final checkDocForReciever = await _firestore
        .collection('chatroom')
        .where("reciever", isEqualTo: user.phoneNumber)
        .get();

    setState(() {
      if (checkDocForSender.docs.isNotEmpty) {
        chatForAdmin = checkDocForSender.docs;
      } else {
        chatForAdmin = checkDocForReciever.docs;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isThisUserAdmin();
    chatAuth();
  }

  @override
  Widget build(BuildContext context) {
    void contactadminfeature() async {
      final user = context.read(authControllerProvider);
      final userFromUsersCollection =
          await _firestore.collection('users').doc(user.uid).get();
      if (userFromUsersCollection.data()["authorization"]) {
        Fluttertoast.showToast(msg: "Your are an Administrator");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatToAdmin(),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Chats"),
      ),
      body: Column(
        children: [
          thisUserAdmin
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onTap: contactadminfeature,
                    leading: Icon(
                      Icons.verified_user,
                      size: 25,
                      color: Colors.red,
                    ),
                    title: Text('Contact Admin',
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    subtitle: Text("Tap here to chat"),
                    trailing: Icon(
                      Icons.chat,
                      color: Colors.red,
                    ),
                  ),
                ),
          thisUserAdmin
              ? Expanded(
                  //child:
                  //Padding(
                  //  padding: const EdgeInsets.only(top: 15.0),
                  //  child: Text("Admins can Search users and initiate chat"),
                  // ),
                  child: ListView(
                    children: chatForAdmin.map((chatRoom) {
                      return ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                            _auth.currentUser.phoneNumber,
                            chatRoom["reciever"],
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                sender: _auth.currentUser.phoneNumber,
                                reciever: chatRoom["reciever"],
                              ),
                            ),
                          );

                          // String roomId = chatRoomId(
                          //   _auth.currentUser.phoneNumber,
                          //   // userMap['number'],
                          // );

                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (_) => ChatRoom(
                          //       chatRoomId: roomId,
                          //       sender: _auth.currentUser.phoneNumber,
                          //       // reciever: userMap['name'],
                          //     ),
                          //   ),
                          // );
                        },
                        leading: Icon(
                          Icons.verified_user,
                          color: Colors.red,
                        ),
                        trailing: Icon(
                          Icons.chat,
                          color: Colors.red,
                        ),
                        title: Text(chatRoom['reciever']),
                        subtitle: Text("by " + chatRoom['sender']),
                      );
                    }).toList(),
                  ),
                )
              : Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text("Admins can Search users and initiate chat"),
                  ),
                ),
        ],
      ),
    );
  }
}

// StreamBuilder<QuerySnapshot>(
//             stream: context
//                 .read(firestoreProvider)
//                 .collection('users')
//                 // .doc()
//                 // .collection('grouptag')
//                 .snapshots(),
//             builder: (
//               BuildContext context,
//               AsyncSnapshot<QuerySnapshot> snapshot,
//             ) {
//               if (snapshot.hasError) {
//                 return Center(
//                   child: Container(
//                     height: 50,
//                     width: 50,
//                     child: Center(
//                       child: Text(
//                         "Something went Wrong!",
//                       ),
//                     ),
//                   ),
//                 );
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(
//                     child: Container(
//                   height: 50,
//                   width: 50,
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 ));
//               }
//               return ListView(
//                 children: snapshot.data.docs.map((DocumentSnapshot document) {
//                   Map<String, dynamic> data =
//                       document.data() as Map<String, dynamic>;
//                   return ListTile(
//                     onTap: () {},
//                     leading: Icon(
//                       Icons.verified_user,
//                       color: Colors.red,
//                     ),
//                     title: Text(data['name']),
//                     subtitle: Text(data['number']),
//                     trailing: Icon(
//                       Icons.chat,
//                       color: Colors.red,
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           )
