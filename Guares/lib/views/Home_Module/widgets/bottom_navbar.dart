import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import '../Bloc/bottom_nav_bloc.dart';
import '../Bloc/bottom_nav_event.dart';
import '../Bloc/bottom_nav_state.dart';

class GuaresBottomNavBar extends StatelessWidget {
  const GuaresBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItem(
                  context,
                  index: 0,
                  icon: Icons.home_rounded,
                  label: "Home",
                  selected: state.currentIndex == 0,
                ),
          
                _buildItem(
                  context,
                  index: 1,
                  icon: Icons.emoji_events_rounded,
                  label: "Challenges",
                  selected: state.currentIndex == 1,
                ),
          
                _buildCreateButton(context),
          
                _buildItem(
                  context,
                  index: 3,
                  icon: Icons.groups_rounded,
                  label: "Community",
                  selected: state.currentIndex == 3,
                ),
          
                _buildItem(
                  context,
                  index: 4,
                  icon: Icons.person_rounded,
                  label: "Profile",
                  selected: state.currentIndex == 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildItem(
  BuildContext context, {
  required int index,
  required IconData icon,
  required String label,
  required bool selected,
}) {
  return GestureDetector(
    onTap: () {
      context.read<BottomNavBloc>().add(
            BottomNavChanged(index),
          );
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 26,
          color: selected
              ? AppColors.primary
              : Colors.white54,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.primary
                : Colors.white54,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCreateButton(BuildContext context) {
  return GestureDetector(
    onTap: () {
      context.read<BottomNavBloc>().add(
            const BottomNavChanged(2),
          );
    },
    child: Container(
      height: 58,
      width: 58,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
        size: 34,
      ),
    ),
  );
}}