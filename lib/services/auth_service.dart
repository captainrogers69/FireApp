import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwhatsapp/general_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseAuthenticationService {
  Stream<User> get userChanges;
  Future<void> signInWithPhone(String phone, BuildContext context);
  Future<void> setDisplayName(String newUsername);
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
  Future<void> signInWithPhone(String phone, BuildContext context) async {
    final _codeController = TextEditingController();
    _read(firebaseAuthProvider).verifyPhoneNumber(
      phoneNumber: "+91" + phone,
      timeout: Duration(seconds: 59),
      verificationCompleted: (AuthCredential credential) async {
        Navigator.of(context).pop();

        UserCredential result =
            await _read(firebaseAuthProvider).signInWithCredential(credential);

        User user = result.user;

        if (user != null) {
          final userInCollection = await _read(firestoreProvider)
              .collection('users')
              .where("number", isEqualTo: user.phoneNumber)
              .get();
          Fluttertoast.showToast(msg: "Login Succesful");

          if (userInCollection.docs.isEmpty) {
            await _read(firestoreProvider)
                .collection('users')
                .doc(user.uid)
                .set({
              "number": phone,
              "name": "unknown",
              "status": "offline",
              "authorization": false,
            });
            Navigator.pop(context);
          } else {
            Fluttertoast.showToast(msg: "Login Succesful");
            // Fluttertoast.showToast(msg: "Account Created");
          }
        } else {
          print("Error");
        }
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception);
      },
      codeSent: (String verificationId, int forceResendingToken) async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Enter the OTP?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("OTP sent to " + phone.toString()),
                    TextField(
                      keyboardType: TextInputType.phone,
                      controller: _codeController,
                      decoration: InputDecoration(
                        // helperText: 'OTP',
                        focusColor: Colors.red,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Text("Confirm"),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: () async {
                      final code = _codeController.text.trim();
                      AuthCredential credential = PhoneAuthProvider.credential(
                          verificationId: verificationId, smsCode: code);

                      UserCredential result = await _read(firebaseAuthProvider)
                          .signInWithCredential(credential);

                      User user = result.user;

                      if (user != null) {
                        final userInCollection = await _read(firestoreProvider)
                            .collection('users')
                            .where("number", isEqualTo: user.phoneNumber)
                            .get();

                        if (userInCollection.docs.isEmpty) {
                          await _read(firestoreProvider)
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            "name": "unknown",
                            "number": phone,
                            "status": "offline",
                            "authorization": false,
                          });
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
            });

        await Future.delayed(Duration(seconds: 59));

        Navigator.pop(context);

        Fluttertoast.showToast(msg: "404! TimeOut");
        Fluttertoast.showToast(msg: "Try again later");
      },
      codeAutoRetrievalTimeout: null,
    );
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
}
