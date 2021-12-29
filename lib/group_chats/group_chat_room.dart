import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutterwhatsapp/group_chats/group_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName, message;
  final List memberslist;
  GroupChatRoom({
    @required this.groupName,
    @required this.groupChatId,
    @required this.message,
    @required this.memberslist,
    Key key,
  }) : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File imageFile;
  // String _fileName;
  // String _saveAsFileName;
  // List<PlatformFile> _paths;
  // String _directoryPath;
  // String _extension;
  // bool _isLoading = false;
  // bool _userAborted = false;
  // bool _multiPick = false;
  // FileType _pickingType = FileType.any;
  // TextEditingController _controller = TextEditingController();

// @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() => _extension = _controller.text);
//   }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }
///////////////////////////////upload filess
  void openFile(PlatformFile file) {
    OpenFile.open(file.path);
  }
  // ignore: missing_return
  Future<File> _saveAsFileName(PlatformFile file ) async {
    // final 
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.groupName),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupInfo(
                  groupMembers: widget.memberslist,
                  groupName: widget.groupName,
                  groupId: widget.groupChatId,
                ),
              ),
            ),
            icon: Icon(
              Icons.info,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //   padding: EdgeInsets.all(4),
              //   height: 25,
              //   child: Text(
              //     message,
              //   ),
              // ),
              Container(
                height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);
                        },
                      );
                    } else {
                      return Container(
                        height: 50,
                        width: 50,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height / 15,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              onPressed: () async {
                                final result = await FilePicker.platform.pickFiles();
                                if (result == null) return;

                                final file = result.files.first;
                                openFile(file);

                                print('Name: ${file.name}');
                                print('Bytes: ${file.bytes}');
                                print('Name: ${file.size}');
                                print('Extension: ${file.extension}');
                                print('path: ${file.path}');

                                await _saveAsFileName(file);

                              },
                              icon: Icon(
                                Icons.document_scanner,
                                color: Colors.red,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(
                                Icons.photo,
                                color: Colors.red,
                              ),
                            ),
                            hintText: "Send Message",
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
                      SizedBox(width: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: onSendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    // final _openImage = OpenFile.open(chatMap['type']);
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              // OpenFile.open(chatMap['type'] == "img" ?? OpenFile.open(chatMap['message']));
                        },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  )),
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              height: size.height / 2.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ClipRRect(child: Image.network
                (
                // PhotoView(
                  // imageProvider: NetworkImage(
                    chatMap['message'],
                    // fit: BoxFit.cover,
                    // loadingBuilder: (BuildContext context, Widget child,
                    //     ImageChunkEvent loadingProgress) {
                    //   if (loadingProgress == null) return child;
                    //   return const Center(
                    //     child: CircularProgressIndicator(
                    //       valueColor:
                    //           AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    //     ),
                    //   );
                    // },
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({
    @required this.imageUrl,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}