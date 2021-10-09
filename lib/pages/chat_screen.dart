import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/pages/broadcast.dart';

class ChatScreen extends StatefulWidget {
  @override
  ChatScreenState createState() {
    return  ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BroadcastScreen()));
      },
      child: const Icon(Icons.chat),
      backgroundColor: Colors.deepOrange,
    ),
      body: GestureDetector(
        onTap: () {
          Future.delayed(Duration(seconds: 1));
          Fluttertoast.showToast(msg: "Cannot message");
        },
        child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                child: Icon(Icons.verified_user),
                // backgroundImage: Icon(Icons.),
                // backgroundColor: Colors.deepPurple,
                // backgroundImage: NetworkImage(
                //     "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Marvel_Logo.svg/1200px-Marvel_Logo.svg.png"),
              ),
              title: Text("+918979642723",
              style: TextStyle(fontWeight: FontWeight.bold,),
              ),
              subtitle: Text(
                "created today",
              ),
            ),
      )
    );
  }
}

// ListView.builder(
//       itemCount: dummyData.length,
//       itemBuilder: (context, i) =>  Column(
//             children: <Widget>[
//                Divider(
//                 height: 10.0,
//               ),
//                ListTile(
//                 leading:  CircleAvatar(
//                   foregroundColor: Theme.of(context).primaryColor,
//                   // backgroundColor: Colors.grey,
//                   backgroundImage:  NetworkImage(dummyData[i].avatarUrl),
//                 ),
//                 title:  Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                      Text(
//                       dummyData[i].name,
//                       style:  TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                      Text(
//                       dummyData[i].time,
//                       style:  TextStyle(color: Colors.grey, fontSize: 14.0),
//                     ),
//                   ],
//                 ),
//                 subtitle:  Container(
//                   padding: const EdgeInsets.only(top: 5.0),
//                   child:  Text(
//                     dummyData[i].message,
//                     style:  TextStyle(color: Colors.grey, fontSize: 15.0),
//                   ),
//                 ),
//               )
//             ],
//           ),
//     ),