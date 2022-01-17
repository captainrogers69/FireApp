import 'package:flutter/material.dart';
import 'package:flutterwhatsapp/services/theme_persistency.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController(ref.read);
});

class ThemeController extends ChangeNotifier {
  final Reader _read;
  bool _theme = false;

  ThemeController(this._read) : super() {
    getTheme();
  }

  bool get theme => _theme;

  Future<void> getTheme() async {
    final theme = await _read(themeServiceProvider).getTheme();

    _theme = theme;

    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    await _read(themeServiceProvider).setTheme(isDark);

    if (isDark) {
      _theme = true;
    } else {
      _theme = false;
    }

    notifyListeners();
  }
}
