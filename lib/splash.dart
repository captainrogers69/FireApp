import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/pages/login.dart';
import 'package:flutterwhatsapp/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkUserStatus(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: aAppLoading()
    );
  }

  void _checkUserStatus(bool user) async {
    await Future.delayed(Duration(seconds: 2));
    aPushReplace(context, LoginPage());
  }
}
