import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/day_entry_model.dart';
import 'core/models/week_entry_model.dart';
import 'data/journey_repository.dart';
import 'app.dart';

// Hive typeId registry:
// 0 = DayEntryAdapter
// 1 = WeekEntryAdapter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DayEntryAdapter());
  Hive.registerAdapter(WeekEntryAdapter());
  await JourneyRepository.instance.init();
  runApp(const MyJourneysApp());
}
