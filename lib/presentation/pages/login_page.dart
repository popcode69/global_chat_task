import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shakuniya_task/logic/auth_bloc/auth_bloc.dart';
import 'package:shakuniya_task/logic/auth_bloc/auth_event.dart';
import 'package:shakuniya_task/logic/auth_bloc/auth_state.dart';
import 'package:shakuniya_task/presentation/pages/profile_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: Scaffold(
        backgroundColor: Colors.deepPurple.shade50,
        body: Center(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
              } else if (state.success) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              }
            },
            builder: (context, state) {
              if (state.loading) {
                return const CircularProgressIndicator();
              }

              return ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(GoogleSignInRequested());
                },
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
