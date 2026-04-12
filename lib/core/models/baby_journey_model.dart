import 'package:hive/hive.dart';
import 'baby_slot_model.dart';
import '../../core/utils/baby_timeline_utils.dart';

class BabyJourney {
  final String babyName;
  final DateTime birthDate;

  const BabyJourney({
    required this.babyName,
    required this.birthDate,
  });

  int get ageInDays => DateTime.now().difference(birthDate).inDays;

  BabySlot get currentSlot =>
      BabyTimelineUtils.slotForDate(birthDate, DateTime.now());
}

// typeId 3 (0 = DayEntry, 1 = WeekEntry, 2 = BabyEntry)
class BabyJourneyAdapter extends TypeAdapter<BabyJourney> {
  @override
  final int typeId = 3;

  @override
  BabyJourney read(BinaryReader reader) {
    final babyName = reader.readString();
    final birthDate =
        DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return BabyJourney(babyName: babyName, birthDate: birthDate);
  }

  @override
  void write(BinaryWriter writer, BabyJourney obj) {
    writer.writeString(obj.babyName);
    writer.writeInt(obj.birthDate.millisecondsSinceEpoch);
  }
}
