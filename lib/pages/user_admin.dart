import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/provider.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/general_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserAdmin extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: context.read(firestoreProvider).collection('users').snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return Center(
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Text(
                    "Something went Wrong!",
                  ),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Container(
              height: 50,
              width: 50,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ));
          }
          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(
                  Icons.verified_user,
                ),
                title: Text(data["name"]),
                subtitle: Text(data['number']),
                trailing: Icon(
                  Icons.chat,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
