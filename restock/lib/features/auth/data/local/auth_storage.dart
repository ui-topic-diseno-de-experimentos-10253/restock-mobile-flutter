
class AuthStorage {
  static int? _userId;
  static String? _token;
  static String? _username;

  Future<void> saveSession({
    required int userId,
    required String token,
    String? username,
  }) async {
    _userId = userId;
    _token = token;
    _username = username;
    print('DEBUG AuthStorage: Session saved - userId: $userId, username: $username, token: ${token.substring(0, 20)}...');
  }

  Future<int?> getUserId() async {
    print('DEBUG AuthStorage: Getting userId: $_userId');
    return _userId;
  }

  Future<String?> getToken() async {
    print('DEBUG AuthStorage: Getting token: ${_token?.substring(0, 20)}...');
    return _token;
  }

  Future<String?> getUsername() async {
    print('DEBUG AuthStorage: Getting username: $_username');
    return _username;
  }
    /// Devuelve toda la sesión de una vez
  Future<AuthSession?> getSession() async {
    if (_userId == null || _token == null) {
      print('[AuthStorage] No session stored');
      return null;
    }
    return AuthSession(
      userId: _userId!,
      token: _token!,
      username: _username,
    );
  }

  Future<void> clear() async {
    print('DEBUG AuthStorage: Clearing session');
    _userId = null;
    _token = null;
    _username = null;
  }
}


class AuthSession {
  final int userId;
  final String token;
  final String? username;

  AuthSession({
    required this.userId,
    required this.token,
    required this.username,
  });
}