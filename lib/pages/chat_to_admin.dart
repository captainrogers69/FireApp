import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
import 'package:uuid/uuid.dart';

class ChatToAdmin extends StatefulWidget {
  const ChatToAdmin({Key key}) : super(key: key);

  @override
  State<ChatToAdmin> createState() => _ChatToAdminState();
}

class _ChatToAdminState extends State<ChatToAdmin> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List adminList = [];

  Future adminListFromFirebase() async {
    final userFromUsersCollection = await _firestore
        .collection('users')
        .where("isAdmin", isEqualTo: true)
        .get();

    setState(() {
      adminList = userFromUsersCollection.docs;
    });
  }

  @override
  void initState() {
    adminListFromFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Choose admin to chat"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
                  children: adminList.map((data) {
            return ListTile(
              onTap: () async {
                final user = context.read(authControllerProvider);
                final checkExists = await _firestore
                    .collection('chatroom')
                    .where(
                      "reciever",
                      isEqualTo: user.phoneNumber,
                    )
                    .where(
                      "sender",
                      isEqualTo: data["number"],
                    )
                    .get();

                final checkExists2 = await _firestore
                    .collection('chatroom')
                    .where(
                      "sender",
                      isEqualTo: user.phoneNumber,
                    )
                    .where(
                      "reciever",
                      isEqualTo: data["number"],
                    )
                    .get();

                final chatRoomIdGenerated = Uuid().v1();
                if (checkExists.docs.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoom(
                        sendername: checkExists.docs[0].data()['senderName'],
                        recieverName:
                            checkExists.docs[0].data()['recieverName'],
                        chatRoomId: checkExists.docs[0].id,
                        sender: checkExists.docs[0].data()['sender'],
                        reciever: checkExists.docs[0].data()['reciever'],
                      ),
                    ),
                  );
                } else if (checkExists2.docs.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoom(
                        sendername: checkExists2.docs[0].data()['senderName'],
                        recieverName:
                            checkExists2.docs[0].data()['recieverName'],
                        chatRoomId: checkExists2.docs[0].id,
                        sender: checkExists2.docs[0].data()['sender'],
                        reciever: checkExists2.docs[0].data()['reciever'],
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoom(
                        sendername: _auth.currentUser.displayName == null
                            ? "unknown"
                            : _auth.currentUser.displayName,
                        recieverName: data["name"],
                        chatRoomId: chatRoomIdGenerated,
                        sender: user.phoneNumber,
                        reciever: data['number'],
                      ),
                    ),
                  );
                }
              }, //initiate one on one chat
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                backgroundImage: AssetImage("fonts/appiconkk.png"),
              ),
              title: Text(data['name']),
              subtitle: Text("Tap here to chat to admin"),
              trailing: Icon(
                Icons.chat,
                color: Colors.red,
              ),
            );
          }).toList())),
        ],
      ),
    );
  }
}
