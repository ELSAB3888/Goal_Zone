import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  String _selectedSport = 'All';

  int get currentIndex => _currentIndex;
  String get selectedSport => _selectedSport;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedSport(String sport) {
    _selectedSport = sport;
    notifyListeners();
  }
}
