import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/Auth/user_Bloc/user_bloc.dart';
import 'package:guares/Auth/user_Bloc/user_state.dart';

import '../Bloc/bottom_nav_bloc.dart';
import '../Bloc/bottom_nav_state.dart';

import '../config/top_bar_config.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning ☀️";
    }

    if (hour >= 12 && hour < 18) {
      return "Good Afternoon 🌤";
    }

    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, navState) {
        final topBar = TopBarConfig.items[navState.currentIndex];

        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            String firstName = "";

            if (userState is UserLoaded) {
              final fullName = userState.user.fullName.trim();

              firstName = fullName.split(" ").first;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topBar.showGreeting ? _getGreeting() : topBar.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              topBar.showGreeting ? firstName : "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Future Badge
                            //
                            // const SizedBox(width: 8),
                            //
                            // User Badge
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    children: topBar.actions.map((action) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: GestureDetector(
                          onTap: action.onPressed,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(action.icon, color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
