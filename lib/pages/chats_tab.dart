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
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool thisUserAdmin = false;
  List<QueryDocumentSnapshot> chatForAdmin = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> isThisUserAdmin() async {
    final user = context.read(authControllerProvider);
    final userFromUsersCollection =
        await _firestore.collection('users').doc(user.uid).get();
    if (userFromUsersCollection.data()["isAdmin"]) {
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
      if (userFromUsersCollection.data()["isAdmin"]) {
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
        title: Text("CHATS"),
      ),
      body: Column(
        children: [
          thisUserAdmin
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onTap: contactadminfeature,
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      backgroundImage: AssetImage("fonts/appiconkk.png"),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomName: chatRoom['chatRoomName'],
                                chatRoomId: chatRoom.id,
                                sender: chatRoom["sender"],
                                sendername: chatRoom["senderName"],
                                reciever: chatRoom["reciever"],
                                recieverName: chatRoom["recieverName"],
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
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          backgroundImage: AssetImage("fonts/appiconkk.png"),
                        ),
                        trailing: Icon(
                          Icons.chat,
                          color: Colors.red,
                        ),
                        title: Text(
                            chatRoom["sender"] == _auth.currentUser.phoneNumber
                                ? chatRoom["reciever"]
                                : chatRoom["sender"]),

                        subtitle: Text("by You"), //chatRoom['sender']),
                      );
                    }).toList(),
                  ),
                )
              : Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    // child: Text("Admins can Search users and initiate chat"),
                  ),
                ),
        ],
      ),
    );
  }
}
