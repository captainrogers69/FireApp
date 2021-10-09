import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/broadcast.dart';
import 'package:flutterwhatsapp/pages/store_page_view.dart';
import 'package:flutterwhatsapp/widgets.dart';

class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff2f2f2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              aPushTo(context, BroadcastScreen());
            },
            child: Card(
              color: Colors.white,
              elevation: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Stack(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.deepPurple,
                        // backgroundImage: NetworkImage(
                        //     "https://s3.amazonaws.com/wll-community-production/images/no-avatar.png"),
                      ),
                      Positioned(
                        bottom: 0.0,
                        right: 1.0,
                        child: Container(
                          height: 20,
                          width: 20,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                  title: Text(
                    "Your Groups",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Tap to Create a New Group"),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Groups Available",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple,
                      // backgroundImage: NetworkImage(
                      //     "https://pbs.twimg.com/media/EClDvMXU4AAw_lt?format=jpg&name=medium"),
                    ),
                    title: Text(
                      "Slade Wilson",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Today, 20:16 PM"),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StoryPageView())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
