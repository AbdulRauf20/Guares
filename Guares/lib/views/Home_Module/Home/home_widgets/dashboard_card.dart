import 'dart:math';
import 'package:flutter/material.dart';
import 'package:guares/Auth/services/theme/app_colors.dart';
import 'package:guares/models/%20home_model.dart';

class DashboardCard extends StatelessWidget {
  final HomeModel home;

  const DashboardCard({super.key, required this.home});

  static final List<String> _quotes = [
    "Small steps every day build extraordinary lives.",
    "Consistency beats intensity when done every day.",
    "Your future is created by what you do today.",
    "One habit today. A better version tomorrow.",
    "Discipline is choosing what you want most.",
    "Success is the sum of small efforts repeated daily.",
    "Every streak starts with one day.",
  ];

  String get randomQuote {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  String formatRank(int rank) {
    if (rank >= 1000000) {
      return "${(rank / 1000000).toStringAsFixed(1)}M";
    }

    if (rank >= 1000) {
      return "${(rank / 1000).toStringAsFixed(1)}K";
    }

    return rank.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    home.fullName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                      ),

                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 18,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          home.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              IconButton(
                onPressed: () {
                  // Future:
                  // Share profile/dashboard card
                },

                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // QUOTE
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),

              borderRadius: BorderRadius.circular(16),
            ),

            child: Text(
              "\"$randomQuote\"",

              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),

                fontSize: 14,

                height: 1.5,

                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Divider(color: Colors.white.withValues(alpha: 0.15)),

          const SizedBox(height: 18),

          // STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              _statItem(
                icon: Icons.local_fire_department_rounded,
                value: home.currentStreak.toString(),
                title: "Streak",
                highlight: true,
              ),

              _statItem(
                icon: Icons.bolt_rounded,
                value: home.longestStreak.toString(),
                title: "Longest",
              ),

              _statItem(
                icon: Icons.star_rounded,
                value: home.level.toString(),
                title: "Level",
              ),

              _statItem(
                icon: Icons.leaderboard_rounded,
                value: formatRank(home.leaderboardRank),
                title: "Rank",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,

    required String value,

    required String title,

    bool highlight = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,

          size: 22,

          color: highlight ? AppColors.primary : Colors.white70,
        ),

        const SizedBox(height: 5),

        Text(
          value,

          style: TextStyle(
            color: highlight ? AppColors.primary : AppColors.textPrimary,

            fontWeight: FontWeight.bold,

            fontSize: 18,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          title,

          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),

            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
