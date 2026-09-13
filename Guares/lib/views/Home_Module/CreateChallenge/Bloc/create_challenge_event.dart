import 'package:equatable/equatable.dart';

import 'package:guares/models/challenge_task_model.dart';

abstract class CreateChallengeEvent extends Equatable {
  const CreateChallengeEvent();

  @override
  List<Object?> get props => [];
}

class CreateChallengeSubmitted extends CreateChallengeEvent {
  final String title;
  final String description;
  final int durationDays;
  final int rewardXP;
  final List<ChallengeTaskModel> tasks;

  const CreateChallengeSubmitted({
    required this.title,
    required this.description,
    required this.durationDays,
    required this.rewardXP,
    required this.tasks,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    durationDays,
    rewardXP,
    tasks,
  ];
}

class ResetCreateChallenge extends CreateChallengeEvent {
  const ResetCreateChallenge();
}
