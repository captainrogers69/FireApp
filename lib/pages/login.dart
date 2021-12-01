import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneNumber = TextEditingController();
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
                    mainAxisAlignment:
                        MainAxisAlignment.center, //spacing from top
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.redAccent,
                        ),
                        height: 65,
                        width: 180,
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
                        height: 14,
                      ),
                      Container(
                        child: Text(
                          "Welcome to KiyaKonnect",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: "Enter Your Phone Number",
                            helperText: "Please add +91",
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                        onPressed: () async {
                          final phone = _phoneNumber.text.trim();
                          await context
                              .read(authenticationServiceProvider)
                              .signInWithPhone(phone, context);
                        },
                        child: Text(
                          "Continue",
                        ),
                      ),
                    ],
                  ),
                ),
                // ),
              ),
            ),
    );
  }
}
