import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/models/community_challenge_model.dart';
import 'package:guares/views/Home_Module/Community/Bloc/community_bloc.dart';
import 'package:guares/views/Home_Module/Community/Bloc/community_event.dart';

class CommunityChallengeDetailsView extends StatelessWidget {
  final CommunityChallengeModel challenge;

  const CommunityChallengeDetailsView({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (challenge.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    challenge.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              challenge.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 10),

            Text(challenge.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _DetailStat(
                    icon: Icons.calendar_today_outlined,
                    value: '${challenge.durationDays}',
                    label: 'Days',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailStat(
                    icon: Icons.star_outline,
                    value: '${challenge.rewardXP}',
                    label: 'XP',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailStat(
                    icon: Icons.people_outline,
                    value: '${challenge.participantsCount}',
                    label: 'Participants',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Created by',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: challenge.creatorProfileImageUrl.isNotEmpty
                      ? NetworkImage(challenge.creatorProfileImageUrl)
                      : null,
                  child: challenge.creatorProfileImageUrl.isEmpty
                      ? const Icon(Icons.person_outline)
                      : null,
                ),

                const SizedBox(width: 12),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.creatorName.isEmpty
                          ? 'Unknown User'
                          : challenge.creatorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (challenge.creatorUsername.isNotEmpty)
                      Text('@${challenge.creatorUsername}'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: challenge.isJoined
    ? null
    : () {
        context.read<CommunityBloc>().add(
          JoinCommunityChallenge(
            challengeId: challenge.id,
          ),
        );
      },
                child: Text(
                  challenge.isJoined ? 'Already Joined' : 'Join Challenge',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailStat({
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
            Icon(icon),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
