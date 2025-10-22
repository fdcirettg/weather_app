import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  //ThemeMode es un enum {system, light, dark}
  ThemeMode _themeMode = ThemeMode.system;
  //obtenemos el valor que está declarado en el sistema
  ThemeMode get themeMode => _themeMode;
  //método para cambiar el tema
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}