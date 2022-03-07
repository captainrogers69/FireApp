// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/general_providers.dart';
import 'package:flutterwhatsapp/hooks/timer_hook.dart';
import 'package:flutterwhatsapp/widgets/error_handler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseAuthenticationService {
  Stream<User> get userChanges;
  Future<void> signInWithPhone(
      String phone, String countryCode, BuildContext context);
  Future<void> setDisplayName(String newUsername);
  Future<void> setProfilePhoto(String photoUrl);
  User getCurrentUser();
  String getCurrentUID();
  Future<void> signOut();
}

final authenticationServiceProvider =
    Provider<AuthenticationService>((ref) => AuthenticationService(ref.read));

class AuthenticationService implements BaseAuthenticationService {
  final Reader _read;

  const AuthenticationService(this._read);

  @override
  String getCurrentUID() => _read(firebaseAuthProvider).currentUser.uid;

  @override
  User getCurrentUser() => _read(firebaseAuthProvider).currentUser;

  @override
  Future<void> signInWithPhone(
      String phone, String countryCode, BuildContext context) async {
    try {
      _read(firebaseAuthProvider).verifyPhoneNumber(
        phoneNumber: "+" + countryCode + phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();

          UserCredential result = await _read(firebaseAuthProvider)
              .signInWithCredential(credential);

          User user = result.user;

          if (user != null) {
            final userInCollection = await _read(firestoreProvider)
                .collection('users')
                .where("number", isEqualTo: user.phoneNumber)
                .get();
            Fluttertoast.showToast(msg: "Login Succesful");

            final token = await FirebaseMessaging.instance.getToken();

            if (userInCollection.docs.isEmpty) {
              await _read(firestoreProvider)
                  .collection('users')
                  .doc(user.uid)
                  .set({
                "number": "+" + countryCode + phone,
                "name": "unknown",
                "status": "offline",
                "token": token,
                "isAdmin": false,
              });
              print(token);
              Navigator.pop(context);
            } else {
              Fluttertoast.showToast(msg: "Login Succesful");
            }
          } else {
            print("Error");
          }
        },
        verificationFailed: (FirebaseAuthException exception) {
          Fluttertoast.showToast(
            msg: exception.toString().length > 35
                ? exception.toString().substring(0, 35) + "..."
                : exception.toString() + " ...",
          );
        },
        codeSent: (String verificationId, int forceResendingToken) async {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return OtpDialogue(
                  verificationID: verificationId,
                  countryCode: countryCode,
                  phoneNumber: phone,
                );
              });

          await Future.delayed(Duration(seconds: 60));

          Navigator.pop(context);

          Fluttertoast.showToast(msg: "TimeOut");
          Fluttertoast.showToast(msg: "Try again later");
        },
        codeAutoRetrievalTimeout: null,
      );
    } on FirebaseAuthException catch (e) {
      return ErrorHandler.errorDialog(context, e);
    }
  }

  @override
  Future<void> signOut() => _read(firebaseAuthProvider).signOut();

  @override
  Stream<User> get userChanges => _read(firebaseAuthProvider).userChanges();

  @override
  Future<void> setDisplayName(String newUsername) async {
    await _read(firebaseAuthProvider)
        .currentUser
        .updateDisplayName(newUsername);

    final user = getCurrentUser();

    await _read(firestoreProvider)
        .collection("users")
        .doc(user.uid)
        .update({"name": user.displayName});
  }

  @override
  Future<void> setProfilePhoto(String photoUrl) async {
    await _read(firebaseAuthProvider).currentUser.updatePhotoURL(photoUrl);
  }
}

class OtpDialogue extends HookWidget {
  final String verificationID, countryCode, phoneNumber;
  const OtpDialogue({
    Key key,
    this.verificationID,
    this.countryCode,
    this.phoneNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticker = useInfiniteTimer();
    final _codeController = useTextEditingController();
    return AlertDialog(
      title: Text("Enter the OTP?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              "This Window will close in ${ticker.toString()} seconds:"), ////////////////
          SizedBox(height: 5),
          // Text("OTP sent to " + phone.toString()),
          TextField(
            keyboardType: TextInputType.phone,
            controller: _codeController,
            decoration: InputDecoration(
              // helperText: 'OTP',
              focusColor: Colors.red,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: Colors.black, //0xffF14C37
                  width: 1.7,
                ),
              ),
              hintText: "Enter Code here",
              //   helperStyle: TextStyle(
              //     color: Colors.red,
              //     fontWeight: FontWeight.bold,
              //     fontSize: 14,
              //   ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.red),
          ),
        ),
        FlatButton(
          child: Text("Confirm"),
          textColor: Colors.white,
          color: Colors.red,
          onPressed: () async {
            final code = _codeController.text.trim();
            AuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationID, smsCode: code);

            UserCredential result = await context
                .read(firebaseAuthProvider)
                .signInWithCredential(credential);

            User user = result.user;

            if (user != null) {
              final userInCollection = await context
                  .read(firestoreProvider)
                  .collection('users')
                  .where("number", isEqualTo: user.phoneNumber)
                  .get();

              if (userInCollection.docs.isEmpty) {
                final token = await FirebaseMessaging.instance.getToken();

                await context
                    .read(firestoreProvider)
                    .collection('users')
                    .doc(user.uid)
                    .set({
                  "name": "unknown",
                  "number": "+" + countryCode + phoneNumber,
                  "status": "offline",
                  "token": token,
                  "isAdmin": false,
                });
                print(token);
                Navigator.pop(context);
              } else {
                Fluttertoast.showToast(msg: "Login Succesful");
              }
            } else {
              Fluttertoast.showToast(msg: "Error");
            }
          },
        )
      ],
    );
  }
}
