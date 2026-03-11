import 'package:hive/hive.dart';
import 'mood_model.dart';

class WeekEntry {
  final int week;
  final Mood? mood;
  final String? journalText;
  final List<String> photoPaths;
  final DateTime? updatedAt;

  const WeekEntry({
    required this.week,
    this.mood,
    this.journalText,
    this.photoPaths = const [],
    this.updatedAt,
  });
}

class WeekEntryAdapter extends TypeAdapter<WeekEntry> {
  @override
  final int typeId = 1;

  @override
  WeekEntry read(BinaryReader reader) {
    final week = reader.readInt();
    final hasMood = reader.readBool();
    final mood = hasMood ? Mood.values[reader.readByte()] : null;
    final hasText = reader.readBool();
    final journalText = hasText ? reader.readString() : null;
    final photoCount = reader.readInt();
    final photoPaths = List.generate(photoCount, (_) => reader.readString());
    final hasUpdatedAt = reader.readBool();
    final updatedAt = hasUpdatedAt
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    return WeekEntry(
      week: week,
      mood: mood,
      journalText: journalText,
      photoPaths: photoPaths,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, WeekEntry obj) {
    writer.writeInt(obj.week);
    writer.writeBool(obj.mood != null);
    if (obj.mood != null) writer.writeByte(obj.mood!.index);
    writer.writeBool(obj.journalText != null);
    if (obj.journalText != null) writer.writeString(obj.journalText!);
    writer.writeInt(obj.photoPaths.length);
    for (final p in obj.photoPaths) {
      writer.writeString(p);
    }
    writer.writeBool(obj.updatedAt != null);
    if (obj.updatedAt != null) {
      writer.writeInt(obj.updatedAt!.millisecondsSinceEpoch);
    }
  }
}
