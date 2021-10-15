import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final groupNameProvider = StateProvider<dynamic>((ref) {
  final groupName = ref
      .read(firestoreProvider)
      .collection("groups").doc().collection('grouptag')
      .get()
      .then((value) => value.docs[0].data());

  return groupName;
});