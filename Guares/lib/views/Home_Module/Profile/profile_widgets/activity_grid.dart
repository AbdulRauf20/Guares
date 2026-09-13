import 'package:flutter/material.dart';

import 'package:guares/models/profile_activity_model.dart';

class ActivityGrid extends StatelessWidget {
  final List<ProfileActivityModel> activities;

  const ActivityGrid({super.key, required this.activities});

  int _activityCount(DateTime date) {
    final activityDate = DateTime(date.year, date.month, date.day);

    for (final activity in activities) {
      final date = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );

      if (date == activityDate) {
        return activity.completedTasks;
      }
    }

    return 0;
  }

  Color _getColor(BuildContext context, int count) {
    final baseColor = Theme.of(context).colorScheme.primary;

    if (count == 0) {
      return baseColor.withOpacity(0.08);
    }

    if (count == 1) {
      return baseColor.withOpacity(0.25);
    }

    if (count <= 3) {
      return baseColor.withOpacity(0.45);
    }

    if (count <= 5) {
      return baseColor.withOpacity(0.70);
    }

    return baseColor.withOpacity(0.95);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // Show the last 12 weeks.
    final startDate = today.subtract(const Duration(days: 83));

    final firstDate = DateTime(startDate.year, startDate.month, startDate.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(12, (weekIndex) {
              return Padding(
                padding: EdgeInsets.only(right: weekIndex == 11 ? 0 : 4),
                child: Column(
                  children: List.generate(7, (dayIndex) {
                    final date = firstDate.add(
                      Duration(days: weekIndex * 7 + dayIndex),
                    );

                    final count = _activityCount(date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message:
                            '${date.day}/${date.month} • $count task${count == 1 ? '' : 's'}',
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _getColor(context, count),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less', style: TextStyle(fontSize: 11)),

            const SizedBox(width: 5),

            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColor(context, index == 0 ? 0 : index),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),

            const Text('More', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
