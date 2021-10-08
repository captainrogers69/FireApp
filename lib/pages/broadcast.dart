import 'package:flutter/material.dart';

class BroadcastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.deepOrange,
          child: Icon(
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
          Container(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                          "https://images-na.ssl-images-amazon.com/images/I/91KQZWNc7LL.jpg"),
                    ),
                    Positioned(
                      top: 5,
                      right: 0,
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text("Clark Kent")
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              // backgroundColor: Colors.deepPurple,
              backgroundImage: NetworkImage(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Marvel_Logo.svg/1200px-Marvel_Logo.svg.png"),
            ),
            title: Text("ElseWorlds"),
            subtitle: Text(
              "Discussion on Earth-38",
            ),
          )
        ]));
  }
}
