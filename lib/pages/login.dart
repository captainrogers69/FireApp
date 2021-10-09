import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';
import 'package:flutterwhatsapp/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneNumber = TextEditingController();
  bool _isLoading = false;
  final _codeController = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  
void loginUser(String phone, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          UserCredential result = await _auth.signInWithCredential(credential);

          User user = result.user;

          if(user != null){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => WhatsAppHome()));
          }else{
            print("Error");
          }

          //This would be called only when verification is done automaticlly
        },
        verificationFailed: (FirebaseAuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Give the code?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _codeController,
                    ),
                  ],
                ),
                actions: <Widget>[
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Text("Confirm"),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () async{
                      final code = _codeController.text.trim();
                      AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);

                      UserCredential result = await _auth.signInWithCredential(credential);

                      User user = result.user;

                      if(user != null){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => WhatsAppHome()
                        ));
                      }else{
                        print("Error");
                      }
                    },
                  )
                ],
              );
            }
          );
        },
        codeAutoRetrievalTimeout: null
    );
  }

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
                        width: 140,
                        child: Center(
                          child: Text(
                            "KiyaKonnect",
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
                          "Welcome to KiyaKonnect",
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      Container(
                        padding: EdgeInsets.all(30),
                        child: TextField(
                          controller: _phoneNumber,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter Your Phone Number",
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: () {
                        final phone = _phoneNumber.text.trim();
                        loginUser(phone, context);
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