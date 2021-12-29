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
    final Size size = MediaQuery.of(context).size;
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
                          color: Colors.red,
                        ),
                        height: 65,
                        width: 180,
                        child: Center(
                          child: Text(
                            "KiyaKonnect",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: TextButton(
                              child: Text(
                                "+91",
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Container(
                            width: size.width / 1.25,
                            padding: EdgeInsets.all(30),
                            child: TextField(
                              controller: _phoneNumber,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                ),
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
                                hintText: "Enter Your Phone Number",
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
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
