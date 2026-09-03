import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import "search_provider.dart";

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? username;

  AuthState({this.isAuthenticated = false, this.token, this.username});

  AuthState copyWith({bool? isAuthenticated, String? token, String? username}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      username: username ?? this.username,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState()) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final username = prefs.getString("username");
    if (token != null) {
      ref.read(apiServiceProvider).setToken(token);
      state = state.copyWith(isAuthenticated: true, token: token, username: username);
    }
  }

  Future<void> login(String username, String password) async {
    final token = await ref.read(apiServiceProvider).login(username, password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("username", username);
    ref.read(apiServiceProvider).setToken(token);
    state = state.copyWith(isAuthenticated: true, token: token, username: username);
  }

  Future<void> register(String username, String password) async {
    await ref.read(apiServiceProvider).register(username, password);
    // After register, auto login
    await login(username, password);
  }

  Future<bool> checkUsername(String username) async {
    return await ref.read(apiServiceProvider).checkUsername(username);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("username");
    ref.read(apiServiceProvider).setToken(null);
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

