import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/models/%20home_model.dart';
import 'package:guares/views/repositories/challenge_repository.dart';
import 'package:guares/views/repositories/home_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  final ChallengeRepository challengeRepository;

  HomeBloc({required this.homeRepository, required this.challengeRepository})
    : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHome>(_onRefreshHome);
    on<CompleteHabit>(_onCompleteHabit);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Load dashboard data
      final HomeModel home = await homeRepository.getHomeData();

      // Load user's joined challenges
      final challenges = await challengeRepository.getJoinedChallenges();

      emit(HomeLoaded(home: home, challenges: challenges));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    add(const LoadHomeData());
  }

  Future<void> _onCompleteHabit(
    CompleteHabit event,
    Emitter<HomeState> emit,
  ) async {
    // Habit completion will be implemented
    // when the habit/challenge completion system is connected.
  }
}
