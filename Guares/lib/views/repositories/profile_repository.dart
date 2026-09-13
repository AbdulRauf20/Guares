import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guares/models/profile_activity_model.dart';

import 'package:guares/models/profile_model.dart';
import 'package:guares/services/firestore_service.dart';

class ProfileRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  ProfileRepository({
    required FirestoreService firestoreService,
    FirebaseAuth? auth,
  }) : _firestoreService = firestoreService,
       _auth = auth ?? FirebaseAuth.instance;

  Future<ProfileModel> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final document = await _firestoreService.getDocument(
      collection: 'users',
      documentId: user.uid,
    );

    final data = document.data() ?? {};

    final activitySnapshot = await _firestoreService.getSubCollection(
      collection: 'users',
      documentId: user.uid,
      subCollection: 'activity',
    );

    final activities = activitySnapshot.docs.map((doc) {
      return ProfileActivityModel.fromMap(doc.id, doc.data());
    }).toList();

    return ProfileModel(
      id: user.uid,
      name: data['name'] ?? user.displayName ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? user.photoURL ?? '',
      totalXP: (data['totalXP'] ?? 0) as int,
      level: (data['level'] ?? 1) as int,
      completedTasks: (data['completedTasks'] ?? 0) as int,
      completedChallenges: (data['completedChallenges'] ?? 0) as int,
      currentStreak: (data['currentStreak'] ?? 0) as int,
      longestStreak: (data['longestStreak'] ?? 0) as int,
      leaderboardRank: (data['leaderboardRank'] ?? 0) as int,
      ownedBadgeIds: List<String>.from(data['ownedBadgeIds'] ?? []),
      activeBadgeId: data['activeBadgeId'],
      activities: activities,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String username,
    required String bio,
    String? profileImageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final data = <String, dynamic>{
      'name': name,
      'username': username,
      'bio': bio,
    };

    if (profileImageUrl != null) {
      data['profileImageUrl'] = profileImageUrl;
    }

    await _firestoreService.updateDocument(
      collection: 'users',
      documentId: user.uid,
      data: data,
    );
  }

  Future<List<ProfileActivityModel>> getActivityHistory() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final snapshot = await _firestoreService.getSubCollection(
      collection: 'users',
      documentId: user.uid,
      subCollection: 'activity',
    );

    return snapshot.docs
        .map((doc) => ProfileActivityModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> recordActivity({
    required DateTime date,
    int completedTasks = 1,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final activityDate = DateTime(date.year, date.month, date.day);

    final documentId =
        '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

    final activityRef = _firestoreService.firestore
        .collection('users')
        .doc(user.uid)
        .collection('activity')
        .doc(documentId);

    await _firestoreService.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(activityRef);

      if (snapshot.exists) {
        final current = (snapshot.data()?['completedTasks'] ?? 0) as int;

        transaction.update(activityRef, {
          'completedTasks': current + completedTasks,
          'date': Timestamp.fromDate(activityDate),
        });
      } else {
        transaction.set(activityRef, {
          'date': Timestamp.fromDate(activityDate),
          'completedTasks': completedTasks,
        });
      }
    });
  }

  Future<void> updateActiveBadge(String? badgeId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    await _firestoreService.updateDocument(
      collection: 'users',
      documentId: user.uid,
      data: {'activeBadgeId': badgeId},
    );
  }
}
