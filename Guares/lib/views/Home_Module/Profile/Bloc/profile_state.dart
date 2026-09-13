import 'package:equatable/equatable.dart';

import 'package:guares/models/profile_activity_model.dart';
import 'package:guares/models/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final List<ProfileActivityModel> activities;

  const ProfileLoaded({required this.profile, this.activities = const []});

  @override
  List<Object?> get props => [profile, activities];
}

class ProfileUpdating extends ProfileState {
  final ProfileModel profile;
  final List<ProfileActivityModel> activities;

  const ProfileUpdating({required this.profile, this.activities = const []});

  @override
  List<Object?> get props => [profile, activities];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
