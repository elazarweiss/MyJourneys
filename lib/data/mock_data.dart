import '../core/models/journey_model.dart';
import '../core/models/milestone_model.dart';
import '../core/models/mood_model.dart';
import '../core/models/week_entry_model.dart';

final Journey mockJourney = Journey(
  name: 'My Journey',
  currentWeek: 36,
  totalWeeks: 40,
  dueDate: DateTime(2026, 11, 4),
  milestones: const [
    Milestone(week: 8, label: 'First Heartbeat', emoji: '💓', reached: true),
    Milestone(week: 12, label: 'First Trimester End', emoji: '🌱', reached: true),
    Milestone(week: 18, label: 'First Kick', emoji: '👣', reached: true),
    Milestone(week: 20, label: 'Anatomy Scan', emoji: '🔬', reached: true),
    Milestone(week: 28, label: 'Third Trimester', emoji: '🌸', reached: true),
    Milestone(week: 36, label: 'Full Term Soon', emoji: '✨', reached: true),
    Milestone(week: 40, label: 'Due Date', emoji: '🎀', reached: false),
  ],
  entries: [
    WeekEntry(
      week: 36,
      date: DateTime(2026, 10, 5),
      mood: Mood.grateful,
      journalText:
          'Feeling so full of gratitude today. Baby has been moving so much — '
          'little kicks and rolls that remind me she\'s almost here. '
          'Spent the afternoon setting up the nursery with soft golden light '
          'streaming in. Everything feels tender and beautiful.',
      photoAssetPath: null,
    ),
    WeekEntry(
      week: 28,
      date: DateTime(2026, 7, 14),
      mood: Mood.joyful,
      journalText: 'Third trimester! Can\'t believe how far we\'ve come.',
      photoAssetPath: null,
    ),
    WeekEntry(
      week: 20,
      date: DateTime(2026, 5, 19),
      mood: Mood.peaceful,
      journalText: 'Anatomy scan went beautifully. Everything looks perfect.',
      photoAssetPath: null,
    ),
  ],
);
