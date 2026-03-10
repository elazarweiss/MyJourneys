enum Mood {
  joyful('Joyful', '😄'),
  grateful('Grateful', '🙏'),
  anxious('Anxious', '😟'),
  tired('Tired', '😴'),
  peaceful('Peaceful', '😌');

  const Mood(this.label, this.emoji);

  final String label;
  final String emoji;
}
