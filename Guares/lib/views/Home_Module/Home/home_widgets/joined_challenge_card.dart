import 'package:flutter/material.dart';

import 'package:guares/models/challenge_preview_model.dart';
import 'package:guares/models/today_task_preview_model.dart';

class JoinedChallengeCard extends StatefulWidget {
  final ChallengePreviewModel challenge;

  const JoinedChallengeCard({super.key, required this.challenge});

  @override
  State<JoinedChallengeCard> createState() => _JoinedChallengeCardState();
}

class _JoinedChallengeCardState extends State<JoinedChallengeCard> {
  bool _isExpanded = false;
  bool _showAllTasks = false;

  static const int _initialTaskLimit = 5;

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;

    final visibleTasks = _showAllTasks
        ? challenge.todayTasks
        : challenge.todayTasks.take(_initialTaskLimit).toList();

    final hasMoreTasks = challenge.todayTasks.length > _initialTaskLimit;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, challenge),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),

                  const SizedBox(height: 8),

                  _buildDescription(context, challenge.description),

                  const SizedBox(height: 16),

                  _buildProgress(context, challenge),

                  const SizedBox(height: 18),

                  _buildTasks(context, visibleTasks),

                  if (hasMoreTasks) ...[
                    const SizedBox(height: 8),
                    _buildSeeMoreButton(context),
                  ],

                  const SizedBox(height: 18),

                  _buildStats(context, challenge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChallengePreviewModel challenge) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    challenge.isStarted
                        ? '${challenge.currentDay}/${challenge.totalDays}'
                        : '${challenge.daysRemaining} days to go',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String description) {
    return Text(
      description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        height: 1.4,
        color: Theme.of(
          context,
        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
      ),
    );
  }

  Widget _buildProgress(BuildContext context, ChallengePreviewModel challenge) {
    final progress = challenge.progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 7),
        ),
      ],
    );
  }

  Widget _buildTasks(BuildContext context, List<TodayTaskPreviewModel> tasks) {
    if (tasks.isEmpty) {
      return Text(
        'No tasks for today.',
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Tasks",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 8),

        ...tasks.map((task) => _buildTaskTile(context, task)),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, TodayTaskPreviewModel task) {
    return InkWell(
      onTap: () {
        // TODO:
        // Connect this to ChallengeBloc
        // when task completion functionality
        // is implemented.
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                // TODO:
                // Dispatch CompleteTaskEvent
              },
            ),

            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 13,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          setState(() {
            _showAllTasks = !_showAllTasks;
          });
        },
        child: Text(_showAllTasks ? 'Show less' : 'See more tasks'),
      ),
    );
  }

  Widget _buildStats(BuildContext context, ChallengePreviewModel challenge) {
    return Row(
      children: [
        Expanded(
          child: _buildStat(
            context,
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${challenge.streak}',
          ),
        ),

        Expanded(
          child: _buildStat(
            context,
            icon: Icons.star_rounded,
            label: 'Reward',
            value: '+${challenge.xpReward} XP',
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),

            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
