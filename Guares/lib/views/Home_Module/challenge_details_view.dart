import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/models/challenge_preview_model.dart';
import 'package:guares/services/firestore_service.dart';
import 'package:guares/views/Challenges_Module/Challenges/Bloc/challenge_bloc.dart';
import 'package:guares/views/Challenges_Module/Challenges/Bloc/challenge_event.dart';
import 'package:guares/views/Challenges_Module/Challenges/Bloc/challenge_state.dart';
import 'package:guares/views/Home_Module/widgets/app_top_bar.dart';
import 'package:guares/views/repositories/challenge_repository.dart';

class ChallengeDetailsView extends StatelessWidget {
  final ChallengePreviewModel challenge;

  const ChallengeDetailsView({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          ChallengeRepository(firestoreService: FirestoreService.instance),
      child: BlocProvider(
        create: (context) =>
            ChallengeBloc(repository: context.read<ChallengeRepository>()),
        child: _ChallengeDetailsBody(challenge: challenge),
      ),
    );
  }
}

class _ChallengeDetailsBody extends StatelessWidget {
  final ChallengePreviewModel challenge;

  const _ChallengeDetailsBody({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(),

            Expanded(
              child: BlocBuilder<ChallengeBloc, ChallengeState>(
                builder: (context, state) {
                  if (state is ChallengeLoaded) {
                    final updatedChallenge = state.challenges.firstWhere(
                      (item) => item.challengeId == challenge.challengeId,
                      orElse: () => challenge,
                    );

                    return _buildContent(context, updatedChallenge);
                  }

                  return _buildContent(context, challenge);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ChallengePreviewModel currentChallenge,
  ) {
    final progress = currentChallenge.progress.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentChallenge.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Text(
            currentChallenge.description,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          const SizedBox(height: 24),

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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(value: progress),

                  const SizedBox(height: 12),

                  Text(
                    'Day ${currentChallenge.currentDay} '
                    'of ${currentChallenge.totalDays}',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '${currentChallenge.streak}',
                  label: 'Streak',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.star_outline,
                  value: '${currentChallenge.xpReward}',
                  label: 'XP Reward',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today_outlined,
                  value: '${currentChallenge.daysRemaining}',
                  label: 'Days Left',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            "Today's Tasks",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 14),

          if (currentChallenge.todayTasks.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No tasks for today.')),
              ),
            ),

          ...currentChallenge.todayTasks.map(
            (task) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: CheckboxListTile(
                value: task.isCompleted,
                onChanged: task.isCompleted
                    ? null
                    : (_) {
                        context.read<ChallengeBloc>().add(
                          CompleteChallengeTask(
                            challengeId: currentChallenge.challengeId,
                            taskId: task.id,
                          ),
                        );
                      },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ],
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
