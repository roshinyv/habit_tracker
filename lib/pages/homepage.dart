import 'package:flutter/material.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/components/my_habit_tile.dart';
import 'package:habit_tracker/components/my_heat_map.dart';
import 'package:habit_tracker/database/habit_db.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/utils/habit_utils.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController _textEditingController = TextEditingController();

  void createHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(hintText: 'Create a new habit'),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              String newHabitname = _textEditingController.text;

              context.read<HabitDatabase>().addHabit(newHabitname);

              Navigator.pop(context);

              _textEditingController.clear();
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);

              _textEditingController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void checkHabitOnOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
      print('checkHabitOnOff================');
    }
  }

  void editHabitBox(Habit habit) {
    _textEditingController.text = habit.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textEditingController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              String newHabitname = _textEditingController.text;

              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitname);

              Navigator.pop(context);

              _textEditingController.clear();
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);

              _textEditingController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deletHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you Sure you want to delete ?"),
        actions: [
          MaterialButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);

              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createHabit,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.add),
        ),
        body: ListView(
          children: [
            _buildHeatMap(),
            _buildHabitList(),
          ],
        ));
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final habit = currentHabits[index];
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deletHabit(habit),
        );
      },
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: habitDatabase.getFirstLauchDate(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHeatMap(
            startDate: snapshot.data,
            datasets: prepHeatMapDataset(currentHabits),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
