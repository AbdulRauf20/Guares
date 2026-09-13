import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/views/repositories/create_challenge_repository.dart';

import 'create_challenge_event.dart';
import 'create_challenge_state.dart';

class CreateChallengeBloc
    extends Bloc<CreateChallengeEvent, CreateChallengeState> {
  final CreateChallengeRepository _repository;

  CreateChallengeBloc({required CreateChallengeRepository repository})
    : _repository = repository,
      super(const CreateChallengeInitial()) {
    on<CreateChallengeSubmitted>(_onCreateChallengeSubmitted);
    on<ResetCreateChallenge>(_onResetCreateChallenge);
  }

  Future<void> _onCreateChallengeSubmitted(
    CreateChallengeSubmitted event,
    Emitter<CreateChallengeState> emit,
  ) async {
    emit(const CreateChallengeLoading());

    try {
      final challengeId = await _repository.createChallenge(
        title: event.title,
        description: event.description,
        durationDays: event.durationDays,
        rewardXP: event.rewardXP,
        tasks: event.tasks,
      );

      emit(CreateChallengeSuccess(challengeId: challengeId));
    } catch (e) {
      emit(CreateChallengeError(message: e.toString()));
    }
  }

  void _onResetCreateChallenge(
    ResetCreateChallenge event,
    Emitter<CreateChallengeState> emit,
  ) {
    emit(const CreateChallengeInitial());
  }
}
