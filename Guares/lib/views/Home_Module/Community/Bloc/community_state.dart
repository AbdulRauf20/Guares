import 'package:equatable/equatable.dart';

import 'package:guares/models/community_challenge_model.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

class CommunityLoaded extends CommunityState {
  final List<CommunityChallengeModel> challenges;

  const CommunityLoaded({required this.challenges});

  @override
  List<Object?> get props => [challenges];
}

class CommunityUpdating extends CommunityState {
  final List<CommunityChallengeModel> challenges;

  const CommunityUpdating({required this.challenges});

  @override
  List<Object?> get props => [challenges];
}

class CommunityError extends CommunityState {
  final String message;

  const CommunityError({required this.message});

  @override
  List<Object?> get props => [message];
}
