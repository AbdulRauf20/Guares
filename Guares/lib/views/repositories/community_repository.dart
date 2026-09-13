import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:guares/models/community_challenge_model.dart';
import 'package:guares/services/firestore_service.dart';

class CommunityRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  CommunityRepository({
    required FirestoreService firestoreService,
    FirebaseAuth? auth,
  }) : _firestoreService = firestoreService,
       _auth = auth ?? FirebaseAuth.instance;

  Future<List<CommunityChallengeModel>> getCommunityChallenges() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final snapshot = await _firestoreService.firestore
        .collection('challenges')
        .where('visibility', isEqualTo: 'Public')
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    final challenges = <CommunityChallengeModel>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final creatorId = data['creatorId'] ?? '';

      final isLiked = await _isChallengeLiked(
        challengeId: doc.id,
        userId: user.uid,
      );

      final isJoined = await _isChallengeJoined(
        challengeId: doc.id,
        userId: user.uid,
      );

      final isFollowing = await _isFollowing(
        creatorId: creatorId,
        userId: user.uid,
      );

      challenges.add(
        CommunityChallengeModel(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          creatorId: creatorId,
          creatorName: data['creatorName'] ?? '',
          creatorUsername: data['creatorUsername'] ?? '',
          creatorProfileImageUrl:
              data['creatorProfileImageUrl'] ?? '',
          durationDays: (data['durationDays'] ?? 0) as int,
          rewardXP: (data['rewardXP'] ?? 0) as int,
          participantsCount:
              (data['participantsCount'] ?? 0) as int,
          likesCount: (data['likesCount'] ?? 0) as int,
          isLiked: isLiked,
          isJoined: isJoined,
          isFollowingCreator: isFollowing,
          createdAt: data['createdAt'] ?? Timestamp.now(),
        ),
      );
    }

    return challenges;
  }

  Future<bool> _isChallengeLiked({
    required String challengeId,
    required String userId,
  }) async {
    final doc = await _firestoreService.firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('likes')
        .doc(userId)
        .get();

    return doc.exists;
  }

  Future<bool> _isChallengeJoined({
    required String challengeId,
    required String userId,
  }) async {
    final doc = await _firestoreService.firestore
        .collection('users')
        .doc(userId)
        .collection('joinedChallenges')
        .doc(challengeId)
        .get();

    return doc.exists;
  }

  Future<bool> _isFollowing({
    required String creatorId,
    required String userId,
  }) async {
    if (creatorId.isEmpty) {
      return false;
    }

    final doc = await _firestoreService.firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(creatorId)
        .get();

    return doc.exists;
  }

  Future<void> toggleLike({
    required String challengeId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final likeRef = _firestoreService.firestore
        .collection('challenges')
        .doc(challengeId)
        .collection('likes')
        .doc(user.uid);

    final likeDoc = await likeRef.get();

    final challengeRef = _firestoreService.firestore
        .collection('challenges')
        .doc(challengeId);

    if (likeDoc.exists) {
      await likeRef.delete();

      await challengeRef.update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await likeRef.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await challengeRef.update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  Future<void> joinChallenge({
    required String challengeId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final challengeRef = _firestoreService.firestore
        .collection('challenges')
        .doc(challengeId);

    final challengeDoc = await challengeRef.get();

    if (!challengeDoc.exists) {
      throw Exception('Challenge not found.');
    }

    // final challengeData = challengeDoc.data()!;

    final joinedRef = _firestoreService.firestore
        .collection('users')
        .doc(user.uid)
        .collection('joinedChallenges')
        .doc(challengeId);

    final joinedDoc = await joinedRef.get();

    if (joinedDoc.exists) {
      return;
    }

    await joinedRef.set({
      'challengeId': challengeId,
      'currentDay': 0,
      'currentStreak': 0,
      'todayTaskProgress': {},
      'startDate': Timestamp.now(),
      'joinedAt': FieldValue.serverTimestamp(),
    });

    await challengeRef.update({
      'participantsCount': FieldValue.increment(1),
    });
  }

  Future<void> toggleFollow({
    required String creatorId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    if (creatorId.isEmpty || creatorId == user.uid) {
      return;
    }

    final followingRef = _firestoreService.firestore
        .collection('users')
        .doc(user.uid)
        .collection('following')
        .doc(creatorId);

    final followingDoc = await followingRef.get();

    final followersRef = _firestoreService.firestore
        .collection('users')
        .doc(creatorId)
        .collection('followers')
        .doc(user.uid);

    if (followingDoc.exists) {
      await followingRef.delete();
      await followersRef.delete();
    } else {
      await followingRef.set({
        'userId': creatorId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await followersRef.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}