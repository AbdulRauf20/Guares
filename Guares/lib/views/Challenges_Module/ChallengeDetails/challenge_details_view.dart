import 'package:flutter/material.dart';

import 'package:guares/models/challenge_preview_model.dart';
import 'package:guares/views/Home_Module/widgets/app_top_bar.dart';

class ChallengeDetailsView extends StatelessWidget {
  static const ChallengePreviewModel defaultChallenge = ChallengePreviewModel(
    challengeId: 'default',
    title: 'Challenge Details',
    description: 'Select a challenge to view details and track daily tasks.',
    currentDay: 1,
    totalDays: 30,
    progress: 0.0,
    streak: 0,
    xpReward: 100,
    isStarted: false,
    daysRemaining: 30,
    todayTasks: [],
  );

  final ChallengePreviewModel challenge;

  const ChallengeDetailsView({
    super.key,
    this.challenge = defaultChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final progress = challenge.progress.clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Challenge title
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      challenge.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            LinearProgressIndicator(value: progress),

                            const SizedBox(height: 12),

                            Text(
                              'Day ${challenge.currentDay} of ${challenge.totalDays}',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department_outlined,
                            value: '${challenge.streak}',
                            label: 'Streak',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _StatCard(
                            icon: Icons.star_outline,
                            value: '${challenge.xpReward}',
                            label: 'XP Reward',
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _StatCard(
                            icon: Icons.calendar_today_outlined,
                            value: '${challenge.daysRemaining}',
                            label: 'Days Left',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Today's Tasks",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (challenge.todayTasks.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text('No tasks for today.')),
                        ),
                      ),

                    ...challenge.todayTasks.map(
                      (task) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                          ),
                          title: Text(task.title),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 22),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
