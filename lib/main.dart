import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutterwhatsapp/controllers/auth_controller.dart';
import 'package:flutterwhatsapp/pages/login.dart';
import 'package:flutterwhatsapp/whatsapp_home.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: theme ? AppTheme.darkTheme : AppTheme.lightTheme,
      theme: ThemeData(primaryColor: Colors.red),
      debugShowCheckedModeBanner: false,
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends HookWidget {
  const AuthChecker({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authControllerState = useProvider(authControllerProvider);
    if (authControllerState != null) {
      return WhatsAppHome();
    } else {
      return LoginPage();
    }
  }
}
