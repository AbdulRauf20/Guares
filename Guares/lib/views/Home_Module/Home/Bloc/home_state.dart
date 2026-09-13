import 'package:equatable/equatable.dart';
import 'package:guares/models/%20home_model.dart';
import 'package:guares/models/challenge_preview_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading State
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loaded State
class HomeLoaded extends HomeState {
  final HomeModel home;
  final List<ChallengePreviewModel> challenges;

  const HomeLoaded({required this.home, required this.challenges});

  @override
  List<Object?> get props => [home, challenges];
}

/// Error State
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
