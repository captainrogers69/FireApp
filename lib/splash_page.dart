import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterwhatsapp/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  startTime() {
    return Timer(const Duration(seconds: 2), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AuthChecker()));
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent[100],
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('fonts/splashk.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
