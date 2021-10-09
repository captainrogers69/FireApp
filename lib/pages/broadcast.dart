import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';
import 'package:flutterwhatsapp/widgets.dart';

class BroadcastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            aAppLoading();
            await Future.delayed(Duration(seconds: 1));
            Fluttertoast.showToast(msg: "Your Group has been Created");
            aPushTo(context, WhatsAppHome());
          },
          backgroundColor: Colors.deepOrange,
          child: 
          Icon(
            Icons.arrow_forward,
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text("New Group"),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.more_vert,
              ),
            )
          ],
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 37,
                          child: Icon(Icons.verified_user),
                        ),
                        Positioned(
                          top: 0.0,
                          right: 1.0,
                          child: Container(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    Text("+919412137383")
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 37,
                          child: Icon(Icons.verified_user),
                        ),
                        Positioned(
                          top: 0.0,
                          right: 1.0,
                          child: Container(
                            height: 20,
                            width: 20,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 15,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8,),
                    Text("+919897200289")
                  ],
                ),
              ),
            ],
          ),
          Divider(),
          Container(
            padding: EdgeInsets.only(top: 8, left: 10,),
            child: Text(
              "Admin",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold,)
              ,
            ),
          ),
          ListTile(
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
              "joined recently",
            ),
          )
        ]));
  }
}
