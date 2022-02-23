import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final String chatRoomName;
  final String sender;
  final String sendername;
  final String reciever;
  final String recieverName;

  ChatRoom({
    this.chatRoomId,
    this.chatRoomName,
    this.sender,
    this.sendername,
    this.reciever,
    this.recieverName,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrolling = ScrollController();
  File imageFile;
  File docFile;
  String documentName;
  File pdfFile;

  Future<void> onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendBy": _auth.currentUser.phoneNumber,
        "sendByName": _auth.currentUser.displayName != ""
            ? _auth.currentUser.displayName
            : "unknown",
        "type": "text",
        "message": _message.text,
        "time": FieldValue.serverTimestamp()
      };

      ////wrap in if condition for doc exists
      // final chatExists = await _firestore
      //     .collection('chatrooom')
      //     .where("chatRoomName", isEqualTo: widget.chatRoomName)
      //     .get();

      // final chatExists2 = await _firestore
      //     .collection('chatroom')
      //     .where("chatRoomAddress", isEqualTo: widget.chatRoomName)
      //     .get();

      // if (chatExists.docs.isNotEmpty || chatExists2.docs.isNotEmpty) {
      await _firestore.collection('chatroom').doc(widget.chatRoomId).set({
        "chatRoomName": widget.chatRoomName,
        "chatRoomAddress": _auth.currentUser.phoneNumber,
        "sender": widget.sender,
        "senderName": widget.sendername != "" ? widget.sendername : "unknown",
        "reciever": widget.reciever,
        "recieverName": widget.recieverName,
      });

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      _message.clear();
    } else {
      print("Enter Some Text");
      Fluttertoast.showToast(msg: "Enter Some Text");
    }
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((result) {
      if (result != null) {
        imageFile = File(result.path);
        setState(() {
          documentName = result.name;
        });
        uploadImage();
      }
    });
  }

  Future getDoc() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
    );
    if (result != null) {
      docFile = File(result.files.single.path);
      setState(() {
        documentName = result.names[0];
      });
      uploadDoc();
    } else {
      Fluttertoast.showToast(msg: "Canceled");
    }
  }

  Future getPDF() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      pdfFile = File(result.files.single.path);
      setState(() {
        documentName = result.names[0];
      });
      uploadPdf();
    } else {
      Fluttertoast.showToast(msg: "Canceled");
    }
  }

  Future uploadDoc() async {
    String docFilename = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(docFilename)
        .set({
      "sendBy": _auth.currentUser.phoneNumber,
      "sendByName": _auth.currentUser.displayName != ""
          ? _auth.currentUser.displayName
          : "unknown",
      "message": "",
      "docname": "",
      "type": "doc",
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('documentFiles')
        .child("$docFile.doc");

    var uploadDocTask = await ref.putFile(docFile).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(docFilename)
          .delete();

      status = 0;
    });
    if (status == 1) {
      String docUrl = await uploadDocTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(docFilename)
          .update({"message": docUrl, "docname": documentName});

      print(docUrl);
    }
  }

  Future uploadPdf() async {
    String pdfFilename = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(pdfFilename)
        .set({
      "sendBy": _auth.currentUser.phoneNumber,
      "sendByName": _auth.currentUser.displayName != ""
          ? _auth.currentUser.displayName
          : "unknown",
      "message": "",
      "docname": "",
      "type": "pdf",
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('documentFiles')
        .child("$pdfFile.pdf");

    var uploadPdfTask = await ref.putFile(pdfFile).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(pdfFilename)
          .delete();

      status = 0;
    });
    if (status == 1) {
      String pdfUrl = await uploadPdfTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(pdfFilename)
          .update({"message": pdfUrl, "docname": documentName});
      print(pdfUrl);
    }
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendBy": _auth.currentUser.phoneNumber,
      "sendByName": _auth.currentUser.displayName != ""
          ? _auth.currentUser.displayName
          : "unknown",
      "docname": "",
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl, "docname": documentName});

      print(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // final chatthisNumber = _firestore
    //     .collection('chatroom')
    //     .where("chatRoomName", isEqualTo: widget.chatRoomName)
    //     .get();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(widget.sender == _auth.currentUser.phoneNumber
              ? widget.reciever
              : widget.sender),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("fonts/background.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 1.29,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(bottom: 5),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chatroom')
                        .doc(widget.chatRoomId)
                        .collection('chats')
                        .orderBy("time", descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            controller: _scrolling,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => {
                                        _scrolling.jumpTo(
                                            _scrolling.position.maxScrollExtent)
                                      });
                              Map<String, dynamic> map =
                                  snapshot.data.docs[index].data();
                              return messages(size, map);
                            });
                      } else {
                        return Container();
                      }
                      //else
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("fonts/background.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  // height: size.height / 10,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          controller: _message,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return documentShareWidget(context);
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.attach_file,
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
              ],
            ),
          ),
        ));
  }

  Widget messages(Size size, Map<String, dynamic> map) {
    return Builder(builder: (_) {
      if (map['type'] == "text") {
        return ChatBubble(
          padding: EdgeInsets.only(
            // top: 3,
            left: 5,
            right: 3,
          ),
          margin: EdgeInsets.only(top: 5),
          clipper: ChatBubbleClipper1(
              type: map['sendBy'] == _auth.currentUser.phoneNumber
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          alignment: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Alignment.centerRight
              : Alignment.centerLeft,
          backGroundColor: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Colors.red
              : Colors.white,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 8,
            ),
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: map['message']));
                Fluttertoast.showToast(msg: "Text Copied to Clipboard");
              },
              child: Linkify(
                text: map['message'],
                onOpen: (link) {
                  launch('${map['message']}');
                },
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: map['sendBy'] == _auth.currentUser.phoneNumber
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else if (map['type'] == "img") {
        return ChatBubble(
          margin: EdgeInsets.only(top: 5),
          clipper: ChatBubbleClipper1(
              type: map['sendBy'] == _auth.currentUser.phoneNumber
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          alignment: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Alignment.centerRight
              : Alignment.centerLeft,
          backGroundColor: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Colors.red
              : Colors.white,
          child: GestureDetector(
            onTap: () {},
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
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              height: size.height / 2.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ClipRRect(
                  child: GestureDetector(
                    onTap: () async {
                      final status = await Permission.storage.request();
                      if (status.isGranted) {
                        final externalDire =
                            await getExternalStorageDirectory();
                        final fileExists = File(
                                "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}")
                            .existsSync();
                        print(fileExists);
                        if (!fileExists) {
                          FlutterDownloader.enqueue(
                            url: map['message'],
                            savedDir: externalDire.path,
                            showNotification: true,
                            openFileFromNotification: true,
                            fileName: map["docname"],
                          );
                        } else {
                          OpenFile.open(
                              "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "permission denied");
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: map['message'] ??
                          "https://img.icons8.com/cute-clipart/2x/user-male.png",
                      placeholder: (context, url) => Container(
                        child: Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          Image.asset("fonts/img_not_available.jpeg"),
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (map['type'] == "doc") {
        return ChatBubble(
          margin: EdgeInsets.only(top: 5),
          clipper: ChatBubbleClipper1(
              type: map['sendBy'] == _auth.currentUser.phoneNumber
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          alignment: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Alignment.centerRight
              : Alignment.centerLeft,
          backGroundColor: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Colors.red
              : Colors.white,
          child: GestureDetector(
            onTap: () async {
              final status = await Permission.storage.request();
              if (status.isGranted) {
                final externalDire = await getExternalStorageDirectory();
                final fileExists = File(
                        "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}")
                    .existsSync();
                print(fileExists);
                if (!fileExists) {
                  FlutterDownloader.enqueue(
                    url: map['message'],
                    savedDir: externalDire.path,
                    showNotification: true,
                    openFileFromNotification: true,
                    fileName: map['docname'],
                  );
                } else {
                  OpenFile.open(
                      "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}");
                }
              } else {
                Fluttertoast.showToast(msg: "denied");
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  )),
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              height: size.height / 14,
              width: size.width / 1.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_copy_rounded,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    map["docname"].length > 15
                        ? map["docname"].substring(0, 15) + "..."
                        : map["docname"] + " ...",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
        );
      } else if (map['type'] == "pdf") {
        return ChatBubble(
          margin: EdgeInsets.only(top: 5),
          clipper: ChatBubbleClipper1(
              type: map['sendBy'] == _auth.currentUser.phoneNumber
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          alignment: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Alignment.centerRight
              : Alignment.centerLeft,
          backGroundColor: map['sendBy'] == _auth.currentUser.phoneNumber
              ? Colors.red
              : Colors.white,
          child: GestureDetector(
            onTap: () async {
              final status = await Permission.storage.request();
              if (status.isGranted) {
                final externalDire = await getExternalStorageDirectory();
                final fileExists = File(
                        "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}")
                    .existsSync();
                print(fileExists);
                if (!fileExists) {
                  FlutterDownloader.enqueue(
                    url: map['message'],
                    savedDir: externalDire.path,
                    showNotification: true,
                    openFileFromNotification: true,
                    fileName: map['docname'],
                  );
                } else {
                  OpenFile.open(
                      "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${map["docname"]}");
                }
              } else {
                Fluttertoast.showToast(msg: "denied");
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  )),
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              height: size.height / 14,
              width: size.width / 1.7,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    map["docname"].length > 15
                        ? map["docname"].substring(0, 15) + "..."
                        : map["docname"] + " ...",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }

  Widget documentShareWidget(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: 30,
      ),
      height: size.height / 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.drag_handle,
          ),
          Text("Share Files"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 37,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => getDoc(),
                        icon: Icon(
                          Icons.file_copy_rounded,
                          // size: 55,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Document")
                ],
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 37,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => getPDF(),
                        icon: Icon(
                          Icons.picture_as_pdf,
                          // size: 55,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("PDF")
                ],
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 37,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => getImage(),
                        icon: Icon(
                          Icons.image,
                          // size: 55,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Gallery")
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShowImageSingle extends StatelessWidget {
  final String imageUrl;

  const ShowImageSingle({
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
