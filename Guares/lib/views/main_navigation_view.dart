import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/views/Home_Module/Bloc/bottom_nav_bloc.dart';
import 'package:guares/views/Home_Module/Bloc/bottom_nav_state.dart';
import 'package:guares/views/Home_Module/challenge_view.dart';
import 'package:guares/views/Home_Module/create_challenge_view.dart';
import 'package:guares/views/Home_Module/community_view.dart';
import 'package:guares/views/Home_Module/home_view.dart';
import 'package:guares/views/Home_Module/profile_view.dart';
import 'package:guares/views/Home_Module/widgets/bottom_navbar.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavBloc(),
      child: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.currentIndex,
              children: const [
                HomeView(),
                ChallengeView(),
                CreateChallengeView(),
                CommunityView(),
                ProfileView(),
              ],
            ),
            bottomNavigationBar: const GuaresBottomNavBar(),
          );
        },
      ),
    );
  }
}
