import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/views/repositories/challenge_repository.dart';

import 'challenge_event.dart';
import 'challenge_state.dart';

class ChallengeBloc extends Bloc<ChallengeEvent, ChallengeState> {
  final ChallengeRepository _repository;

  ChallengeBloc({required ChallengeRepository repository})
    : _repository = repository,
      super(const ChallengeInitial()) {
    on<LoadJoinedChallenges>(_onLoadJoinedChallenges);
    on<RefreshChallenges>(_onRefreshChallenges);
    on<CompleteChallengeTask>(_onCompleteChallengeTask);
    on<LoadAvailableChallenges>(_onLoadAvailableChallenges);
    on<JoinChallenge>(_onJoinChallenge);
  }
  Future<void> _onLoadAvailableChallenges(
    LoadAvailableChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading());

    try {
      final challenges = await _repository.getAvailableChallenges();

      emit(AvailableChallengesLoaded(challenges: challenges));
    } catch (e) {
      emit(ChallengeError(message: e.toString()));
    }
  }

  Future<void> _onJoinChallenge(
    JoinChallenge event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      await _repository.joinChallenge(challengeId: event.challengeId);

      add(const LoadJoinedChallenges());
    } catch (e) {
      emit(ChallengeError(message: e.toString()));
    }
  }

  Future<void> _onLoadJoinedChallenges(
    LoadJoinedChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    emit(const ChallengeLoading());

    try {
      final challenges = await _repository.getJoinedChallenges();

      emit(ChallengeLoaded(challenges: challenges));
    } catch (e) {
      emit(ChallengeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshChallenges(
    RefreshChallenges event,
    Emitter<ChallengeState> emit,
  ) async {
    add(const LoadJoinedChallenges());
  }

  Future<void> _onCompleteChallengeTask(
    CompleteChallengeTask event,
    Emitter<ChallengeState> emit,
  ) async {
    try {
      await _repository.completeTask(
        challengeId: event.challengeId,
        taskId: event.taskId,
      );

      add(const LoadJoinedChallenges());
    } catch (e) {
      emit(ChallengeError(message: e.toString()));
    }
  }
}
