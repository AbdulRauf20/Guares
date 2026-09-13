import 'package:guares/models/challenge_preview_model.dart';

class HomeModel {
  final String fullName;
  final int currentStreak;
  final int longestStreak;
  final int xp;
  final int level;
  final String badge;
  final int leaderboardRank;
  final List<ChallengePreviewModel> joinedChallenges;

  const HomeModel({
    required this.leaderboardRank,
    required this.fullName,
    required this.currentStreak,
    required this.longestStreak,
    required this.xp,
    required this.level,
    required this.badge,
    required this.joinedChallenges,
  });

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      leaderboardRank: map['leaderboardRank'] ?? 0,
      fullName: map['fullName'] ?? '',
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      badge: map['badge'] ?? 'Beginner',

      // Joined challenges are NOT stored in the user document.
      // They are loaded separately by ChallengeRepository.
      joinedChallenges: const [],
    );
  }

  HomeModel copyWith({
    String? fullName,
    int? currentStreak,
    int? longestStreak,
    int? xp,
    int? level,
    String? badge,
    int? leaderboardRank,
    List<ChallengePreviewModel>? joinedChallenges,
  }) {
    return HomeModel(
      fullName: fullName ?? this.fullName,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      badge: badge ?? this.badge,
      leaderboardRank: leaderboardRank ?? this.leaderboardRank,
      joinedChallenges: joinedChallenges ?? this.joinedChallenges,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'xp': xp,
      'level': level,
      'badge': badge,
      'leaderboardRank': leaderboardRank,
    };
  }
}
