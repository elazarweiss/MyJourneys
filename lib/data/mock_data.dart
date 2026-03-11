import '../core/models/journey_model.dart';
import '../core/models/milestone_model.dart';

// Due date chosen so currentWeek computes to approximately week 36
// (today ≈ March 12 2026, conception = dueDate - 280 days = Jul 10 2025,
//  March 12 2026 - Jul 10 2025 = 246 days → week 36)
final Journey mockJourney = Journey(
  name: 'My Journey',
  dueDate: DateTime(2026, 4, 16),
  milestones: const [
    Milestone(week: 8,  label: 'First Heartbeat',   emoji: '💓', reached: true),
    Milestone(week: 12, label: 'First Trimester End',emoji: '🌱', reached: true),
    Milestone(week: 18, label: 'First Kick',         emoji: '👣', reached: true),
    Milestone(week: 20, label: 'Anatomy Scan',       emoji: '🔬', reached: true),
    Milestone(week: 28, label: 'Third Trimester',    emoji: '🌸', reached: true),
    Milestone(week: 36, label: 'Full Term Soon',     emoji: '✨', reached: true),
    Milestone(week: 40, label: 'Due Date',           emoji: '🎀', reached: false),
  ],
);
