import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../services/firestore_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService = FirestoreService();

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<CheckEmailVerificationRequested>(_onCheckEmailVerificationRequested);
    on<CompleteProfileRequested>(_onCompleteProfileRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResendVerificationEmailRequested>(_onResendVerificationEmailRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<FacebookSignInRequested>(_onFacebookSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
  }

  

  Future<void> _onResendVerificationEmailRequested(
    ResendVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.resendVerificationEmail();

      emit(EmailNotVerified());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
  Future<void> _onFacebookSignInRequested(
  FacebookSignInRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final userCredential =
        await _authService.signInWithFacebook();

    final user = userCredential.user;

    if (user == null) {
      emit(AuthFailure(message: "Facebook sign in failed."));
      return;
    }

    final isNewUser =
        userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      emit(ProfileIncomplete());
      return;
    }

    final profileCompleted =
        await _firestoreService.isProfileCompleted(user.uid);

    if (!profileCompleted) {
      emit(ProfileIncomplete());
      return;
    }

    emit(
      Authenticated(
        emailVerified: true,
        profileCompleted: true,
      ),
    );
  } catch (e) {
    emit(AuthFailure(message: e.toString()));
  }
}

  /// Login
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final userCredential = await _authService.login(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;

      if (user == null) {
        emit(AuthFailure(message: "User not found."));
        return;
      }

      if (!user.emailVerified) {
        emit(EmailNotVerified());
        return;
      }

      final profileCompleted = await _firestoreService.isProfileCompleted(
        user.uid,
      );

      if (!profileCompleted) {
        emit(ProfileIncomplete());
        return;
      }

      emit(Authenticated(emailVerified: true, profileCompleted: true));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onAppleSignInRequested(
  AppleSignInRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final credential =
        await _authService.signInWithApple();

    await _handleSocialLogin(credential, emit);
  } catch (e) {
    emit(AuthFailure(message: e.toString()));
  }
}

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final userCredential = await _authService.signInWithGoogle();

      final user = userCredential.user;

      if (user == null) {
        emit(AuthFailure(message: "Google sign in failed."));
        return;
      }

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        emit(ProfileIncomplete());
        return;
      }

      final profileCompleted = await _firestoreService.isProfileCompleted(
        user.uid,
      );

      if (!profileCompleted) {
        emit(ProfileIncomplete());
        return;
      }

      emit(Authenticated(emailVerified: true, profileCompleted: true));
    } catch (e) {
      // If the user simply backed out of the Google dialog, don't show an error.
      if (e.toString().toLowerCase().contains("cancel")) {
        emit(Unauthenticated());
        return;
      }

      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Signup
  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final userCredential = await _authService.signup(
        email: event.email,
        password: event.password,
      );

      final user = userCredential.user;

      if (user == null) {
        emit(AuthFailure(message: 'Failed to create account.'));
        return;
      }

      await user.sendEmailVerification();

      emit(EmailNotVerified());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Forgot Password
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.forgotPassword(email: event.email);

      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Check if user is already logged in
  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await _authService.getCurrentUser();

      if (user == null) {
        emit(Unauthenticated());
        return;
      }

      if (!user.emailVerified) {
        emit(EmailNotVerified());
        return;
      }

      final isCompleted = await _firestoreService.isProfileCompleted(user.uid);

      if (!isCompleted) {
        emit(ProfileIncomplete());
        return;
      }

      emit(Authenticated(emailVerified: true, profileCompleted: true));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Check Email Verification
  Future<void> _onCheckEmailVerificationRequested(
    CheckEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isVerified = await _authService.isEmailVerified();

      if (isVerified) {
        emit(ProfileIncomplete());
      } else {
        emit(EmailNotVerified());
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  /// Complete Profile
  Future<void> _onCompleteProfileRequested(
    CompleteProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We will implement this after integrating Cloud Firestore.
  }

  /// Logout
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.logout();

      emit(Unauthenticated());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _handleSocialLogin(
    dynamic userCredential,
    Emitter<AuthState> emit,
  ) async {
    final user = userCredential.user;

    if (user == null) {
      emit(AuthFailure(message: "Social sign in failed."));
      return;
    }

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      emit(ProfileIncomplete());
      return;
    }

    final profileCompleted = await _firestoreService.isProfileCompleted(
      user.uid,
    );

    if (!profileCompleted) {
      emit(ProfileIncomplete());
      return;
    }

    emit(Authenticated(emailVerified: true, profileCompleted: true));
  }
}

