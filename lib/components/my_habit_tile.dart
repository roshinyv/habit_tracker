import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyHabitTile extends StatelessWidget {
  final String text;
  final bool isCompleted;
  void Function(bool?)? onChanged;
  void Function(BuildContext)? editHabit;
  void Function(BuildContext)? deleteHabit;

  MyHabitTile({
    Key? key,
    required this.text,
    required this.isCompleted,
    required this.onChanged,
    required this.editHabit,
    required this.deleteHabit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(motion: StretchMotion(), children: [
          SlidableAction(
            onPressed: editHabit,
            backgroundColor: Colors.grey.shade800,
            icon: Icons.settings,
            borderRadius: BorderRadius.circular(8),
          ),
          SlidableAction(
            onPressed: deleteHabit,
            backgroundColor: Colors.red.shade800,
            icon: Icons.delete,
            borderRadius: BorderRadius.circular(8),
          ),
        ]),
        child: GestureDetector(
          onTap: () {
            if (onChanged != null) {
              onChanged!(!isCompleted);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(text),
              leading: Checkbox(
                  activeColor: Colors.green,
                  value: isCompleted,
                  onChanged: onChanged),
            ),
          ),
        ),
      ),
    );
  }
}
