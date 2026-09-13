import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:guares/models/profile_activity_model.dart';

class ProfileModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String profileImageUrl;

  final int totalXP;
  final int level;

  final int completedTasks;
  final int completedChallenges;

  final int currentStreak;
  final int longestStreak;

  final int leaderboardRank;

  final List<String> ownedBadgeIds;
  final String? activeBadgeId;

  // Daily activity:
  // key = date, e.g. "2026-08-20"
  // value = number of completed tasks that day
  final List<ProfileActivityModel> activities;
  final Timestamp createdAt;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImageUrl,
    required this.totalXP,
    required this.level,
    required this.completedTasks,
    required this.completedChallenges,
    required this.currentStreak,
    required this.longestStreak,
    required this.leaderboardRank,
    required this.ownedBadgeIds,
    this.activeBadgeId,
    required this.activities,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    bio,
    profileImageUrl,
    totalXP,
    level,
    completedTasks,
    completedChallenges,
    currentStreak,
    longestStreak,
    leaderboardRank,
    ownedBadgeIds,
    activeBadgeId,
    activities,
    createdAt,
  ];
}
