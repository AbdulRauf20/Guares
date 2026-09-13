import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guares/models/challenge_model.dart';

import 'package:guares/models/challenge_preview_model.dart';
import 'package:guares/models/today_task_preview_model.dart';
import 'package:guares/services/firestore_service.dart';
import 'package:guares/views/repositories/profile_repository.dart';

class ChallengeRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final ProfileRepository _profileRepository;

  ChallengeRepository({
    required FirestoreService firestoreService,
    FirebaseAuth? auth,
    ProfileRepository? profileRepository,
  }) : _firestoreService = firestoreService,
       _auth = auth ?? FirebaseAuth.instance,
       _profileRepository =
           profileRepository ??
           ProfileRepository(firestoreService: firestoreService, auth: auth);

  /// Loads all active challenges joined by the current user.
  Future<List<ChallengePreviewModel>> getJoinedChallenges() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final joinedSnapshot = await _firestoreService.getSubCollection(
      collection: 'users',
      documentId: user.uid,
      subCollection: 'joinedChallenges',
    );

    final List<ChallengePreviewModel> challenges = [];

    for (final joinedDoc in joinedSnapshot.docs) {
      final joinedData = joinedDoc.data();

      final challengeId = joinedData['challengeId'] ?? joinedDoc.id;

      final challengeDoc = await _firestoreService.getDocument(
        collection: 'challenges',
        documentId: challengeId,
      );

      if (!challengeDoc.exists || challengeDoc.data() == null) {
        continue;
      }

      final challengeData = challengeDoc.data()!;

      final tasks = await _getTodayTasks(
        challengeId: challengeId,
        joinedData: joinedData,
      );

      final totalDays = (challengeData['durationDays'] ?? 30) as int;

      final currentDay = (joinedData['currentDay'] ?? 0) as int;

      final progress = totalDays == 0 ? 0.0 : currentDay / totalDays;

      final startDate = _toDateTime(joinedData['startDate']);

      final isStarted = startDate != null && !startDate.isAfter(DateTime.now());

      final daysRemaining = isStarted
          ? (totalDays - currentDay).clamp(0, totalDays)
          : _calculateDaysUntil(startDate);

      challenges.add(
        ChallengePreviewModel(
          challengeId: challengeId,
          title: challengeData['title'] ?? '',
          description: challengeData['description'] ?? '',
          currentDay: currentDay,
          totalDays: totalDays,
          progress: progress.clamp(0.0, 1.0),
          streak: (joinedData['currentStreak'] ?? 0) as int,
          xpReward: (challengeData['rewardXP'] ?? 0) as int,
          isStarted: isStarted,
          daysRemaining: daysRemaining,
          todayTasks: tasks,
        ),
      );
    }

    return challenges;
  }

  /// Marks a specific task within a joined challenge as completed.
  Future<void> completeTask({
    required String challengeId,
    required String taskId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    await _firestoreService.updateDocument(
      collection: 'users/${user.uid}/joinedChallenges',
      documentId: challengeId,
      data: {'todayTaskProgress.$taskId': true},
    );

    await _profileRepository.recordActivity(date: DateTime.now());
  }

  Future<List<ChallengeModel>> getAvailableChallenges() async {
    final snapshot = await _firestoreService.getCollection(
      collection: 'challenges',
    );

    return snapshot.docs
        .map((doc) {
          final data = doc.data();

          return ChallengeModel.fromMap({...data, 'id': doc.id});
        })
        .where((challenge) => !challenge.isArchived)
        .toList();
  }

  Future<void> joinChallenge({required String challengeId}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final challengeDoc = await _firestoreService.getDocument(
      collection: 'challenges',
      documentId: challengeId,
    );

    if (!challengeDoc.exists || challengeDoc.data() == null) {
      throw Exception('Challenge not found.');
    }

    // final challengeData = challengeDoc.data()!;

    final joinedChallengeRef = _firestoreService.firestore
        .collection('users')
        .doc(user.uid)
        .collection('joinedChallenges')
        .doc(challengeId);

    await joinedChallengeRef.set({
      'challengeId': challengeId,
      'currentDay': 0,
      'currentStreak': 0,
      'todayTaskProgress': {},
      'startDate': FieldValue.serverTimestamp(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await _firestoreService.incrementField(
      collection: 'challenges',
      documentId: challengeId,
      field: 'participantsCount',
    );
  }

  /// Loads today's task definitions and combines them with
  /// the user's completion state.
  Future<List<TodayTaskPreviewModel>> _getTodayTasks({
    required String challengeId,
    required Map<String, dynamic> joinedData,
  }) async {
    final taskSnapshot = await _firestoreService.getSubCollection(
      collection: 'challenges',
      documentId: challengeId,
      subCollection: 'tasks',
    );

    final completedTasks = Map<String, dynamic>.from(
      joinedData['todayTaskProgress'] ?? {},
    );

    return taskSnapshot.docs.map((doc) {
      final data = doc.data();

      return TodayTaskPreviewModel(
        id: doc.id,
        title: data['title'] ?? '',
        isCompleted: completedTasks[doc.id] == true,
      );
    }).toList();
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  int _calculateDaysUntil(DateTime? startDate) {
    if (startDate == null) {
      return 0;
    }

    final difference = startDate.difference(DateTime.now()).inDays;

    return difference < 0 ? 0 : difference;
  }

  Future<void> createChallenge({required ChallengeModel challenge}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final challengeRef = FirebaseFirestore.instance
        .collection('challenges')
        .doc();

    await challengeRef.set({
      ...challenge.toMap(),
      'creatorId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    for (final task in challenge.tasks) {
      await challengeRef.collection('tasks').doc().set({
        ...task.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
