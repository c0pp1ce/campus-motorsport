import 'package:flutter/material.dart';

class BaseProvider extends ChangeNotifier {
  bool disposed = false;

  void notify() {
    if (!disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
