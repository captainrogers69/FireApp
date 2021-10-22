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
      phoneNumber: phone,
      timeout: Duration(seconds: 30),
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

            await _read(firestoreProvider).collection('users').doc(user.uid).set({
              "number": phone,
              "name": "",
              "status": "offline",
              "authorization" : false,
            });
          } else {
            Fluttertoast.showToast(msg: "Account Created");
          }
        } else {
          print("Error");
        }
      },
      verificationFailed: (FirebaseAuthException exception) {
        print(exception);
      },
      codeSent: (String verificationId, [int forceResendingToken]) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text("Enter the OTP?"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.phone,
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

                              .doc(user.uid).set({
                            "name": "",
                            "number": phone,
                            "status": "offline",
                            "authorization" : false,
                          });

                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(msg: "Account Created");
                        }
                      } else {
                        print("Error");
                      }
                    },
                  )
                ],
              );
            });
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