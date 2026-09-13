import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/services/firestore_service.dart';

import 'package:guares/views/Home_Module/Home/Bloc/home_bloc.dart';
import 'package:guares/views/Home_Module/Home/Bloc/home_event.dart';
import 'package:guares/views/Home_Module/Home/Bloc/home_state.dart';

import 'package:guares/views/Home_Module/Home/home_widgets/dashboard_card.dart';
import 'package:guares/views/Home_Module/Home/home_widgets/joined_challenges_section.dart';
import 'package:guares/views/Home_Module/widgets/app_top_bar.dart';
import 'package:guares/views/repositories/challenge_repository.dart';
import 'package:guares/views/repositories/home_repository.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ChallengeRepository>(
          create: (_) =>
              ChallengeRepository(firestoreService: FirestoreService.instance),
        ),

        RepositoryProvider<HomeRepository>(
          create: (context) => HomeRepository(
            firestoreService: FirestoreService.instance,
            challengeRepository: context.read<ChallengeRepository>(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => HomeBloc(
          homeRepository: context.read<HomeRepository>(),
          challengeRepository: context.read<ChallengeRepository>(),
        )..add(const LoadHomeData()),

        child: const _HomeViewBody(),
      ),
    );
  }
}

class _HomeViewBody extends StatelessWidget {
  const _HomeViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),

                      const SizedBox(height: 16),

                      const Text(
                        'Unable to load Home',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(state.message, textAlign: TextAlign.center),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeBloc>().add(const LoadHomeData());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is HomeLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppTopBar(),

                    const SizedBox(height: 10),

                    DashboardCard(home: state.home),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: JoinedChallengesSection(
                        challenges: state.home.joinedChallenges,
                        onViewAll: () {
                          // Connect to Challenges page later.
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
