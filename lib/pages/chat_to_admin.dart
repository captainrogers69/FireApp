import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';

class ChatToAdmin extends StatefulWidget {
  const ChatToAdmin({Key key}) : super(key: key);

  @override
  State<ChatToAdmin> createState() => _ChatToAdminState();
}

class _ChatToAdminState extends State<ChatToAdmin> {

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List adminList = [];

    String chatRoomId(String user1, user2) {
      if (user1[0].toLowerCase().codeUnits[0] >
          user2.toLowerCase().codeUnits[0]) {
        return "$user1$user2";
      } else {
        return "$user2$user1";
      }
    }

    Future adminListFromFirebase() async {
      final userFromUsersCollection = await _firestore
          .collection('users')
          .where("authorization", isEqualTo: true)
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
        backgroundColor: Colors.redAccent,
        title: Text("Choose admin to chat"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
                  children: adminList.map((data) {
            return ListTile(
              onTap: () {
                final chatRoomIdGenerated = chatRoomId(data['number'],
                    context.read(authControllerProvider).phoneNumber);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(
                        chatRoomId: chatRoomIdGenerated,
                        sender: data['number'],
                        reciever:
                            context.read(authControllerProvider).phoneNumber),
                  ),
                );
              }, //initiate one on one chat
              leading: Icon(
                Icons.verified_user,
                color: Colors.redAccent,
              ),
              title: Text(data['name']),
              subtitle: Text(data['number']),
              trailing: Icon(
                Icons.chat,
                color: Colors.redAccent,
              ),
            );
          }).toList())),
        ],
      ),
    );
  }
}
