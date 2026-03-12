import 'package:flutter/foundation.dart';
import '../../data/mock_data.dart';

class ShellNavigationState extends ChangeNotifier {
  int _currentMode = 0;
  int _focusedWeek;
  int _focusedDayWeek;
  int _focusedDayIndex;
  bool _showCalendarWeekDetail = false;

  ShellNavigationState()
      : _focusedWeek = mockJourney.currentWeek,
        _focusedDayWeek = mockJourney.currentWeek,
        _focusedDayIndex = _todayDayIndex();

  static int _todayDayIndex() {
    return (DateTime.now().weekday - 1).clamp(0, 6);
  }

  int get currentMode => _currentMode;
  int get focusedWeek => _focusedWeek;
  int get focusedDayWeek => _focusedDayWeek;
  int get focusedDayIndex => _focusedDayIndex;
  bool get showCalendarWeekDetail => _showCalendarWeekDetail;

  void switchMode(int mode) {
    if (_currentMode == mode) return;
    _currentMode = mode;
    notifyListeners();
  }

  void focusWeek(int week) {
    _focusedWeek = week;
    notifyListeners();
  }

  void focusDay(int week, int dayIndex) {
    _focusedDayWeek = week;
    _focusedDayIndex = dayIndex;
    notifyListeners();
  }

  /// Called from the clothesline when a week dot is tapped.
  /// Switches to Calendar mode and flags that the week detail should be shown.
  void openCalendarWeekDetail(int week) {
    _focusedWeek = week;
    _showCalendarWeekDetail = true;
    _currentMode = 1;
    notifyListeners();
  }

  /// Called by CalendarModeScreen once it has consumed the detail request.
  void clearCalendarWeekDetailRequest() {
    _showCalendarWeekDetail = false;
    // No notify — this is just a flag reset consumed in didChangeDependencies.
  }
}
