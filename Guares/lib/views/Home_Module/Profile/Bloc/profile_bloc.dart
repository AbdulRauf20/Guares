import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/views/repositories/profile_repository.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateActiveBadge>(_onUpdateActiveBadge);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      final profile = await _repository.getProfile();
      final activities = await _repository.getActivityHistory();

      emit(ProfileLoaded(profile: profile, activities: activities));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    add(const LoadProfile());
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is! ProfileLoaded) {
      return;
    }

    emit(
      ProfileUpdating(
        profile: currentState.profile,
        activities: currentState.activities,
      ),
    );

    try {
      await _repository.updateProfile(
        name: event.name,
        username: event.username,
        bio: event.bio,
        profileImageUrl: event.profileImageUrl,
      );

      final updatedProfile = await _repository.getProfile();

      emit(
        ProfileLoaded(
          profile: updatedProfile,
          activities: currentState.activities,
        ),
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateActiveBadge(
    UpdateActiveBadge event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is! ProfileLoaded) {
      return;
    }

    emit(
      ProfileUpdating(
        profile: currentState.profile,
        activities: currentState.activities,
      ),
    );

    try {
      await _repository.updateActiveBadge(event.badgeId);

      final updatedProfile = await _repository.getProfile();

      emit(
        ProfileLoaded(
          profile: updatedProfile,
          activities: currentState.activities,
        ),
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
