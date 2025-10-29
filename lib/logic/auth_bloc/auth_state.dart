import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool loading;
  final bool success;
  final String? error;

  const AuthState({
    this.loading = false,
    this.success = false,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    bool? success,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, success, error];
}
