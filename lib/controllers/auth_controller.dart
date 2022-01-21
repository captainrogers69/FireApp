import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterwhatsapp/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authControllerProvider =
    StateNotifierProvider<AuthenticationController, User>((ref) {
  return AuthenticationController(ref.read);
});

class AuthenticationController extends StateNotifier<User> {
  final Reader _read;

  StreamSubscription<User> _authStateChangesSubscription;

  AuthenticationController(this._read) : super(null) {
    _authStateChangesSubscription?.cancel();
    _authStateChangesSubscription = _read(authenticationServiceProvider)
        .userChanges
        .listen((user) => state = user);
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  Future<void> setProfilePhoto(String photoUrl) async {
    await _read(authenticationServiceProvider).setProfilePhoto(photoUrl);
  }
}
