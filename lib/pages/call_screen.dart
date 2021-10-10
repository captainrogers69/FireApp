import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/chat_screen.dart';
 
//home screen

class CallsScreen extends StatefulWidget {
  @override
  _CallsScreenState createState() => _CallsScreenState();
}
// with WidgetsBindingObserver
class _CallsScreenState extends State<CallsScreen>  {
  bool isloading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> userMap;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  //   setStatus("Online");
  // }

  // void setStatus(String status) async {

  //   await _firestore.collection('users').doc(_auth.currentUser.uid).update({
  //     "status": status,});
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
    
  //   if(state == AppLifecycleState.resumed) {
  //     //online
  //     setStatus("online");
  //   }else{
  //     //offline
  //     setStatus("offline");
  //   }
  // }

  String chatRoomId(String user1, user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
    user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isloading = true;
    });

    await _firestore
        .collection('users')
        .where("number", isEqualTo: _search.text)
        .get()
        .then((value)  {
          setState(() {
            userMap = (value).docs[0].data();
            isloading = false;
          });
        print(userMap);       
        });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isloading
          ? Center(
              child: Container(
                height: 100,
                width: 100,
                // height: MediaQuery.of(context).size.height,
                // width: MediaQuery.of(context).size.width,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                Container(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        hintText: "Search",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )),
                ElevatedButton(
                  onPressed: onSearch,
                  child: Text(
                    "search",
                  ),
                ),
                userMap != null ? ListTile(
                  onTap: () {

                    String roomId = chatRoomId(
                      _auth.currentUser.phoneNumber,
                      // userMap['status'],
                      userMap['number'],
                      
                    );

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatRoom(
                        chatRoomId: roomId ,
                        userMap: userMap,
                        ),),);
                  },
                  leading: Icon(Icons.verified_user),
                  title: Text(userMap['number']),
                  subtitle: Text("Name here"),
                  trailing: Icon(Icons.chat),
                ) 
                : Container(),
              ],
            ),
    );
  }
}
