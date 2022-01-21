import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/general_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class BaseStorageService {
  Future<void> uploadProfileImage(File file);
  Future<String> getDownloadUrl();
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.read);
});

class StorageService implements BaseStorageService {
  final Reader _read;

  const StorageService(this._read);

  @override
  // ignore: missing_return
  Future<String> uploadProfileImage(File file) async {
    try {
      final userUID = _read(authControllerProvider).uid;
      final storageRef =
          _read(firebaseStorageProvider).ref().child("users/profile/$userUID");
      await storageRef.putFile(file);
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  @override
  Future<String> getDownloadUrl() async {
    final userUID = _read(authControllerProvider).uid;
    final downloadedUrl = await _read(firebaseStorageProvider)
        .ref("users/profile/$userUID")
        .getDownloadURL();

    return downloadedUrl;
  }
}
