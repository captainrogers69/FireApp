import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';


class OtpVerify extends StatefulWidget {
  OtpVerify({Key key}) : super(key: key);

  @override
  _OtpVerifyState createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final _otp = TextEditingController();

  bool _isLoading = false;

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: _isLoading
          ? aAppLoading()
          : Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 300,
                  ),
                  Container(
                    color: Colors.lightBlue,
                    height: 50,
                    width: 115,
                    child: Center(
                      child: Text(
                        "ChatsPro",
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  Container(
                    child: Text(
                      "Phone Number Verification",
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Container(
                    padding: EdgeInsets.all(30),
                    child: TextField(
                      controller: _otp,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter Otp",
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => WhatsAppHome()));
                    },
                    child: Text(
                      "Continue",
                    ),
                  )
                ],
              ),
            ),
          // ),
        ),
      ),
    );
  }
}


Widget aAppLoading() {
  return Container(
    color: Colors.white,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}