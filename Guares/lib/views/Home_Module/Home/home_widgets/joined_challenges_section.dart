import 'package:flutter/material.dart';

import 'package:guares/models/challenge_preview_model.dart';
import 'joined_challenge_card.dart';

class JoinedChallengesSection extends StatelessWidget {
  final List<ChallengePreviewModel> challenges;
  final VoidCallback? onViewAll;

  const JoinedChallengesSection({
    super.key,
    required this.challenges,
    this.onViewAll,
  });

  static const int _maxVisibleChallenges = 3;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return _buildEmptyState(context);
    }

    final visibleChallenges = challenges.take(_maxVisibleChallenges).toList();

    final hasMoreChallenges = challenges.length > _maxVisibleChallenges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, hasMoreChallenges),

        const SizedBox(height: 14),

        ...visibleChallenges.map(
          (challenge) => JoinedChallengeCard(challenge: challenge),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool hasMoreChallenges) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Your Challenges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),

        if (hasMoreChallenges)
          TextButton(onPressed: onViewAll, child: const Text('View All')),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 36,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),

          const SizedBox(height: 10),

          const Text(
            'No challenges yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 5),

          Text(
            'Join a challenge and start building your consistency.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
