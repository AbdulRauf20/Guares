import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guares/Auth/services/firestore_service.dart';

import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

final FirestoreService _firestoreService = FirestoreService();

  UserBloc() : super(UserInitial()) {

    on<LoadUserRequested>(_loadUser);
    on<RefreshUserRequested>(_refreshUser);
    on<UpdateUserRequested>(_updateUser);
  }

  Future<void> _loadUser(
  LoadUserRequested event,
  Emitter<UserState> emit,
) async {
  emit(UserLoading());

  try {
    final user = await _firestoreService.getCurrentUser();

    emit(UserLoaded(user));
  } catch (e) {
    emit(UserFailure(e.toString()));
  }
}

  Future<void> _refreshUser(
      RefreshUserRequested event,
      Emitter<UserState> emit,
  ) async {}

  Future<void> _updateUser(
      UpdateUserRequested event,
      Emitter<UserState> emit,
  ) async {}
}