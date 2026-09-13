import 'package:equatable/equatable.dart';
import 'package:guares/models/challenge_model.dart';

import 'package:guares/models/challenge_preview_model.dart';

abstract class ChallengeState extends Equatable {
  const ChallengeState();

  @override
  List<Object?> get props => [];
}

class ChallengeInitial extends ChallengeState {
  const ChallengeInitial();
}

class ChallengeLoading extends ChallengeState {
  const ChallengeLoading();
}

class ChallengeLoaded extends ChallengeState {
  final List<ChallengePreviewModel> challenges;

  const ChallengeLoaded({required this.challenges});

  @override
  List<Object?> get props => [challenges];
}

class ChallengeError extends ChallengeState {
  final String message;

  const ChallengeError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AvailableChallengesLoaded extends ChallengeState {
  final List<ChallengeModel> challenges;

  const AvailableChallengesLoaded({required this.challenges});

  @override
  List<Object?> get props => [challenges];
}
