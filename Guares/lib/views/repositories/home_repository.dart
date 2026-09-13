import 'package:firebase_auth/firebase_auth.dart';

import 'package:guares/models/%20home_model.dart';
import 'package:guares/services/firestore_service.dart';
import 'package:guares/views/repositories/challenge_repository.dart';

class HomeRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final ChallengeRepository _challengeRepository;

  HomeRepository({
    required FirestoreService firestoreService,
    FirebaseAuth? auth,
    required ChallengeRepository challengeRepository,
  }) : _firestoreService = firestoreService,
       _auth = auth ?? FirebaseAuth.instance,
       _challengeRepository = challengeRepository;

  Future<HomeModel> getHomeData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in.');
    }

    final userDoc = await _firestoreService.getDocument(
      collection: 'users',
      documentId: user.uid,
    );

    if (!userDoc.exists || userDoc.data() == null) {
      throw Exception('User data not found.');
    }

    final joinedChallenges = await _challengeRepository.getJoinedChallenges();

    final home = HomeModel.fromMap(userDoc.data()!);

    return home.copyWith(joinedChallenges: joinedChallenges);
  }
}
