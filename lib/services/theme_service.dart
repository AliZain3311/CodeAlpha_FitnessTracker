import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  static const String _boxName = 'fittrack_theme_box';
  static const String _darkModeKey = 'dark_mode';

  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }

    final dynamic savedValue = Hive.box(_boxName).get(_darkModeKey);

    isDarkMode.value = savedValue == true;
  }

  static bool get darkMode => isDarkMode.value;

  static Future<void> setDarkMode(bool enabled) async {
    isDarkMode.value = enabled;

    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }

    await Hive.box(_boxName).put(_darkModeKey, enabled);
  }

  static Future<void> toggle() async {
    await setDarkMode(!isDarkMode.value);
  }
}
