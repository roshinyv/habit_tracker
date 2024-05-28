import 'package:flutter/material.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
  }

  Future<void> savefirstLaunchDate() async {
    final existingsettings = await isar.appSettings.where().findFirst();
    if (existingsettings == null) {
      final settings = AppSettings()..firstLauchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLauchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLauchDate;
  }

  final List<Habit> currentHabits = [];

  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..text = habitName;
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabits();
  }

  Future<void> readHabits() async {
    List<Habit> fetchHabits = await isar.habits.where().findAll();
    currentHabits.clear();
    currentHabits.addAll(fetchHabits);
    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (Habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit!.completedDays.contains(DateTime.now())) {
          final today = DateTime.now();
          habit.completedDays.add(
            DateTime(today.year, today.month, today.day),
          );
        } else {
          habit!.completedDays.removeWhere((date) =>
              date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
      });
    }
    await isar.habits.put(habit!);
  }
}
