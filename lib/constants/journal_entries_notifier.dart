import 'package:flutter/material.dart';

class JournalEntriesNotifier extends ChangeNotifier {
  bool _hasNewEntry = false;

  bool get hasNewEntry => _hasNewEntry;

  void setNewEntry(bool value) {
    _hasNewEntry = value;
    notifyListeners();
  }
}
