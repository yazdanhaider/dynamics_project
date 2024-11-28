import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  Color _seedColor = Colors.blue;

  ThemeProvider() : _themeData = _createThemeData(Colors.blue);

  ThemeData get themeData => _themeData;
  Color get seedColor => _seedColor;

  static ThemeData _createThemeData(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      brightness: Brightness.dark,
    );
  }

  void updateTheme(Color newSeedColor) {
    _seedColor = newSeedColor;
    _themeData = _createThemeData(newSeedColor);
    notifyListeners();
  }

  static ThemeProvider of(BuildContext context) {
    return Provider.of<ThemeProvider>(context, listen: false);
  }
}
