import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habithub/Auth/Bloc/auth_bloc.dart';
import 'package:habithub/Auth/services/auth_service.dart';
import 'package:habithub/Auth/user_Bloc/user_bloc.dart';
import 'package:habithub/firebase_options.dart';
import 'package:habithub/views/splash_screen_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authService: AuthService()),
        ),
        BlocProvider<UserBloc>(create: (_) => UserBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HabitHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22C55E)),
      ),
      home: const SplashScreenView(),
    );
  }
}
