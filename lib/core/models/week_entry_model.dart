import 'mood_model.dart';

class WeekEntry {
  final int week;
  final DateTime date;
  final Mood? mood;
  final String? journalText;
  final String? photoAssetPath;

  const WeekEntry({
    required this.week,
    required this.date,
    this.mood,
    this.journalText,
    this.photoAssetPath,
  });
}
