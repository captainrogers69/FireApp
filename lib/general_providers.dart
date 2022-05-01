import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// final useFromUsersCollectionProvider = Provider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
//   final user = ref.read(authControllerProvider);
//   final userFromUsersCollection =  ref.read(firestoreProvider).collection('users').doc(user.uid).get();
//   return userFromUsersCollection;
// });

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) =>
    FirebaseStorage.instanceFor(bucket: "gs://kiyakonnect.appspot.com"));

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final groupNameProvider = StateProvider<dynamic>((ref) {
  final groupName = ref
      .read(firestoreProvider)
      .collection("groups")
      .doc()
      .collection('grouptag')
      .get()
      .then((value) => value.docs[0].data());

  return groupName;
});
