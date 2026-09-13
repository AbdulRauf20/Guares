import 'package:flutter/material.dart';
import 'package:guares/models/challenge_preview_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengePreviewModel challenge;
  final VoidCallback? onTap;

  const ChallengeCard({super.key, required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // Description
              Text(
                challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),

              const SizedBox(height: 16),

              // Progress
              Row(
                children: [
                  Text(
                    'Day ${challenge.currentDay}/${challenge.totalDays}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const Spacer(),

                  Text(
                    '${(challenge.progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              LinearProgressIndicator(
                value: challenge.progress.clamp(0.0, 1.0),
              ),

              const SizedBox(height: 14),

              // Stats
              Row(
                children: [
                  _Stat(
                    icon: Icons.local_fire_department_outlined,
                    label: '${challenge.streak}',
                    tooltip: 'Current streak',
                  ),

                  const SizedBox(width: 18),

                  _Stat(
                    icon: Icons.star_outline,
                    label: '${challenge.xpReward} XP',
                    tooltip: 'XP reward',
                  ),

                  const SizedBox(width: 18),

                  _Stat(
                    icon: Icons.calendar_today_outlined,
                    label: '${challenge.daysRemaining}d',
                    tooltip: 'Days remaining',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Open button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: const Text('Open Challenge'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _Stat({required this.icon, required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
