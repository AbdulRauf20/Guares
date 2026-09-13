import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/models/community_challenge_model.dart';
import 'package:guares/services/firestore_service.dart';
import 'package:guares/views/Home_Module/Community/Bloc/community_bloc.dart';
import 'package:guares/views/Home_Module/Community/Bloc/community_event.dart';
import 'package:guares/views/Home_Module/Community/Bloc/community_state.dart';
import 'package:guares/views/Home_Module/Community/community_challenge_details_view.dart';
import 'package:guares/views/Home_Module/widgets/app_top_bar.dart';
import 'package:guares/views/repositories/community_repository.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) =>
          CommunityRepository(firestoreService: FirestoreService.instance),
      child: BlocProvider(
        create: (context) =>
            CommunityBloc(
              repository: context.read<CommunityRepository>(),
            )..add(const LoadCommunity()),
        child: const _CommunityBody(),
      ),
    );
  }
}

class _CommunityBody extends StatelessWidget {
  const _CommunityBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppTopBar(),

            Expanded(
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  if (state is CommunityLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is CommunityError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (state is CommunityLoaded) {
                    if (state.challenges.isEmpty) {
                      return const Center(
                        child: Text('No public challenges yet.'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CommunityBloc>().add(
                          const RefreshCommunity(),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.challenges.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _CommunityChallengeCard(
                            challenge: state.challenges[index],
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Community'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityChallengeCard extends StatelessWidget {
  final CommunityChallengeModel challenge;

  const _CommunityChallengeCard({
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CommunityChallengeDetailsView(
            challenge: challenge,
          ),
        ),
      );
    },
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Creator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      challenge.creatorProfileImageUrl.isNotEmpty
                      ? NetworkImage(
                          challenge.creatorProfileImageUrl,
                        )
                      : null,
                  child: challenge.creatorProfileImageUrl.isEmpty
                      ? const Icon(Icons.person_outline)
                      : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.creatorName.isEmpty
                            ? 'Unknown User'
                            : challenge.creatorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (challenge.creatorUsername.isNotEmpty)
                        Text(
                          '@${challenge.creatorUsername}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: challenge.isFollowingCreator
                      ? null
                      : () {
                          context.read<CommunityBloc>().add(
                            ToggleCommunityCreatorFollow(
                              creatorId: challenge.creatorId,
                            ),
                          );
                        },
                  child: Text(
                    challenge.isFollowingCreator
                        ? 'Following'
                        : 'Follow',
                  ),
                ),
              ],
            ),
          ),

          // Image
          if (challenge.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                challenge.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const SizedBox.shrink();
                },
              ),
            ),

          // Challenge content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  challenge.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${challenge.durationDays} days',
                    ),
                    _InfoChip(
                      icon: Icons.star_outline,
                      label: '${challenge.rewardXP} XP',
                    ),
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${challenge.participantsCount}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<CommunityBloc>().add(
                      ToggleCommunityChallengeLike(
                        challengeId: challenge.id,
                      ),
                    );
                  },
                  icon: Icon(
                    challenge.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),

                Text('${challenge.likesCount}'),

                const SizedBox(width: 8),

                Expanded(
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
                      challenge.isJoined ? 'Joined' : 'Join Challenge',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}