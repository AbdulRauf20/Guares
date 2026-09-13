import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:guares/models/challenge_model.dart';
import 'package:guares/models/challenge_task_model.dart';
import 'package:guares/services/firestore_service.dart';

class CreateChallengeRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  CreateChallengeRepository({
    required FirestoreService firestoreService,
    FirebaseAuth? auth,
  }) : _firestoreService = firestoreService,
       _auth = auth ?? FirebaseAuth.instance;

  Future<String> createChallenge({
    required String title,
    required String description,
    required int durationDays,
    required int rewardXP,
    required List<ChallengeTaskModel> tasks,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final challengeId = _firestoreService.firestore
        .collection('challenges')
        .doc()
        .id;

    final challenge = ChallengeModel(
      id: challengeId,
      title: title,
      description: description,
      imageUrl: '',
      creatorId: user.uid,
      category: 'General',
      difficulty: 'Easy',
      visibility: 'Public',
      durationDays: durationDays,
      rewardXP: rewardXP,
      rewardCoins: 0,
      participantsCount: 0,
      maxParticipants: 0,
      rules: const [],
      tasks: tasks,
      createdAt: Timestamp.now(),
      isArchived: false,
    );

    await _firestoreService.setDocument(
      collection: 'challenges',
      documentId: challengeId,
      data: challenge.toMap(),
    );

    for (final task in tasks) {
      await _firestoreService.setDocument(
        collection: 'challenges/$challengeId/tasks',
        documentId: task.id,
        data: task.toMap(),
      );
    }

    return challengeId;
  }
}
