class UserCredentialsStore {
  static String? _username;
  static String? _password;

  static String? get username => _username;
  static String? get password => _password;

  static bool get hasCredentials =>
      _username != null && _username!.isNotEmpty && _password != null && _password!.isNotEmpty;

  static void setCredentials({
    required String username,
    required String password,
  }) {
    _username = username;
    _password = password;
  }
}
