import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home:  SplashScreen(),
    );
  }
}
