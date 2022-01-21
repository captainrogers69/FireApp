import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutterwhatsapp/group_chats/group_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class _GroupChatRoomState extends State<GroupChatRoom>
    with SingleTickerProviderStateMixin {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File imageFile;
  File docFile;
  String documentName;
  File pdfFile;
  int progress = 0;
  ReceivePort _receivePort = ReceivePort();
  TransformationController _tranformationController;
  TapDownDetails tabDownDetails;
  AnimationController animationController;
  Animation<Matrix4> animation;

  static downloadingCallback(id, status, progress) {
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort.send([id, status, progress]);
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((result) {
      if (result != null) {
        imageFile = File(result.path);
        print(result.name);
        setState(() {
          documentName = result.name;
        });
        uploadImage();
      } else {
        Fluttertoast.showToast(msg: "Canceled");
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
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(docFilename)
        .set({
      "sendby": _auth.currentUser.displayName,
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
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(docFilename)
          .delete();

      status = 0;
    });
    if (status == 1) {
      String docUrl = await uploadDocTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
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
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(pdfFilename)
        .set({
      "sendby": _auth.currentUser.displayName,
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
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(pdfFilename)
          .delete();

      status = 0;
    });
    if (status == 1) {
      String pdfUrl = await uploadPdfTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
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
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser.displayName,
      "message": "",
      "docname": "",
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
          .update({"message": imageUrl, "docname": documentName});

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

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });
    });
    FlutterDownloader.registerCallback((downloadingCallback));
    _tranformationController = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        _tranformationController.value = animation.value;
      });
  }

  @override
  void dispose() {
    _tranformationController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Row(
          children: [
            // CircleAvatar(
            //   backgroundImage: NetworkImage(
            //       //authControllerState
            //       //.photoURL ??
            //       "https://fanfest.com/wp-content/uploads/2021/02/Loki.jpg"),
            // ),
            // SizedBox(width: 4),
            Text(widget.groupName),
          ],
        ),
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
                height: size.height / 1.25,
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
                  // margin: EdgeInsets.only(bottom: 10),
                  height: size.height / 14,
                  width: size.width / 1.1,
                  child: Column(
                    children: [
                      // LinearProgressIndicator(
                      //   backgroundColor: Colors.white,
                      //   valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      //   value: progress.toDouble(),
                      //   minHeight: 2,
                      // ),
                      SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: size.height / 15,
                            width: size.width / 1.3,
                            child: TextField(
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
            ),
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
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
                    // onDoubleTapDown: (details) => tabDownDetails = details,
                    // onDoubleTap: () {
                    //   final position = tabDownDetails.localPosition;

                    //   final double scale = 3;
                    //   final x = -position.dx * (scale - 1);
                    //   final y = -position.dy * (scale - 1);
                    //   final zoomed = Matrix4.identity()
                    //     ..translate(x, y)
                    //     ..scale(scale);

                    //   final end = _tranformationController.value.isIdentity()
                    //       ? zoomed
                    //       : Matrix4.identity();
                    //   _tranformationController.value = end;
                    //   animation = Matrix4Tween(
                    //           begin: _tranformationController.value, end: end)
                    //       .animate(CurveTween(curve: Curves.easeOut)
                    //           .animate(animationController));
                    onTap: () async {
                      final status = await Permission.storage.request();
                      if (status.isGranted) {
                        final externalDire =
                            await getExternalStorageDirectory();
                        final fileExists = File(
                                "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}")
                            .existsSync();
                        print(fileExists);
                        if (!fileExists) {
                          FlutterDownloader.enqueue(
                            url: chatMap['message'],
                            savedDir: externalDire.path,
                            showNotification: true,
                            openFileFromNotification: true,
                            fileName: chatMap["docname"],
                          );
                        } else {
                          OpenFile.open(
                              "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "permission denied");
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: chatMap['message'] ??
                          "https://img.icons8.com/cute-clipart/2x/user-male.png",
                      placeholder: (context, url) => Container(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (chatMap['type'] == "doc") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () async {
              final status = await Permission.storage.request();
              if (status.isGranted) {
                final externalDire = await getExternalStorageDirectory();
                final fileExists = File(
                        "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}")
                    .existsSync();
                print(fileExists);
                if (!fileExists) {
                  FlutterDownloader.enqueue(
                    url: chatMap['message'],
                    savedDir: externalDire.path,
                    showNotification: true,
                    openFileFromNotification: true,
                    fileName: chatMap['docname'],
                  );
                } else {
                  OpenFile.open(
                      "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}");
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
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
                    chatMap["docname"].length > 15
                        ? chatMap["docname"].substring(0, 15) + "..."
                        : chatMap["docname"] + " ...",
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
      } else if (chatMap['type'] == "pdf") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] == _auth.currentUser.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () async {
              final status = await Permission.storage.request();
              if (status.isGranted) {
                final externalDire = await getExternalStorageDirectory();
                final fileExists = File(
                        "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}")
                    .existsSync();
                print(fileExists);
                if (!fileExists) {
                  FlutterDownloader.enqueue(
                    url: chatMap['message'],
                    savedDir: externalDire.path,
                    showNotification: true,
                    openFileFromNotification: true,
                    fileName: chatMap['docname'],
                  );
                } else {
                  OpenFile.open(
                      "/storage/emulated/0/Android/data/com.example.flutterwhatsapp/files/${chatMap["docname"]}");
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
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              height: size.height / 11,
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
                    chatMap["docname"].length > 15
                        ? chatMap["docname"].substring(0, 15) + "..."
                        : chatMap["docname"] + " ...",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => getDoc(),
                    icon: Icon(
                      Icons.file_copy_rounded,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Document")
                ],
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => getPDF(),
                    icon: Icon(
                      Icons.picture_as_pdf,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("PDF")
                ],
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => getImage(),
                    icon: Icon(
                      Icons.image,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Image")
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
