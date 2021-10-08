import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';


Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "WhatsApp",
      theme:  ThemeData(
        primaryColor:  Color(0xff075E54),
        accentColor:  Color(0xff25D366),
      ),
      debugShowCheckedModeBanner: false,
      home:  WhatsAppHome(),
    );
  }
}
