import 'package:hive/hive.dart';
import 'mood_model.dart';

class DayEntry {
  final int week;
  final int dayIndex; // 0=Mon … 6=Sun
  final DateTime date;
  final Mood? mood;
  final String? quickNote; // max 80 chars

  DayEntry({
    required this.week,
    required this.dayIndex,
    required this.date,
    this.mood,
    this.quickNote,
  });
}

class DayEntryAdapter extends TypeAdapter<DayEntry> {
  @override
  final int typeId = 0;

  @override
  DayEntry read(BinaryReader reader) {
    final week = reader.readInt();
    final dayIndex = reader.readInt();
    final dateMs = reader.readInt();
    final hasMood = reader.readBool();
    final mood = hasMood ? Mood.values[reader.readByte()] : null;
    final hasNote = reader.readBool();
    final quickNote = hasNote ? reader.readString() : null;
    return DayEntry(
      week: week,
      dayIndex: dayIndex,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
      mood: mood,
      quickNote: quickNote,
    );
  }

  @override
  void write(BinaryWriter writer, DayEntry obj) {
    writer.writeInt(obj.week);
    writer.writeInt(obj.dayIndex);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.mood != null);
    if (obj.mood != null) writer.writeByte(obj.mood!.index);
    writer.writeBool(obj.quickNote != null);
    if (obj.quickNote != null) writer.writeString(obj.quickNote!);
  }
}
