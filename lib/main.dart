
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shakuniya_task/services/firebase_options.dart';
import 'package:shakuniya_task/logic/chat_bloc/chat_event.dart';
import 'package:shakuniya_task/presentation/pages/login_page.dart';
import 'package:shakuniya_task/presentation/pages/profile_page.dart';
import 'data/repositories/chat_repository.dart';
import 'logic/chat_bloc/chat_bloc.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM
  await FirebaseMessaging.instance.requestPermission();
  await FcmService().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ChatRepository chatRepository = ChatRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ChatBloc(chatRepository)..add(LoadMessagesEvent())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Global Chat',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const ProfilePage();
        }
        return const LoginPage();
      },
    );
  }
}
