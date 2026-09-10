import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';

class AuthService {
  static const String _usersBoxName = 'fittrack_users_box';

  static const String _sessionBoxName = 'fittrack_session_box';

  static const String _usersKey = 'users';

  static const String _currentUserIdKey = 'current_user_id';

  static const Uuid _uuid = Uuid();

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      await Hive.openBox(_usersBoxName);
    }

    if (!Hive.isBoxOpen(_sessionBoxName)) {
      await Hive.openBox(_sessionBoxName);
    }
  }

  static Box get _usersBox {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      throw StateError(
        'AuthService is not initialized. '
        'Call AuthService.init() first.',
      );
    }

    return Hive.box(_usersBoxName);
  }

  static Box get _sessionBox {
    if (!Hive.isBoxOpen(_sessionBoxName)) {
      throw StateError(
        'AuthService is not initialized. '
        'Call AuthService.init() first.',
      );
    }

    return Hive.box(_sessionBoxName);
  }

  static List<AppUser> getAllUsers() {
    if (!Hive.isBoxOpen(_usersBoxName)) {
      return <AppUser>[];
    }

    final dynamic data = _usersBox.get(_usersKey, defaultValue: <dynamic>[]);

    if (data is! List) {
      return <AppUser>[];
    }

    return data
        .whereType<Map>()
        .map((item) => AppUser.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Creates a new account.
  ///
  /// IMPORTANT:
  /// Registration does NOT automatically log the user in.
  /// The user must go to Login and enter the same
  /// email/password to access the dashboard.
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await init();

    final String normalizedEmail = email.trim().toLowerCase();

    final List<AppUser> users = getAllUsers();

    final bool emailExists = users.any(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );

    if (emailExists) {
      return 'An account with this email already exists.';
    }

    final AppUser newUser = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );

    users.add(newUser);

    await _saveUsers(users);

    // Make sure registration does NOT create
    // an active login session.
    await _sessionBox.delete(_currentUserIdKey);

    return null;
  }

  /// Logs in using the registered email and password.
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    await init();

    final String normalizedEmail = email.trim().toLowerCase();

    final List<AppUser> users = getAllUsers();

    AppUser? matchedUser;

    for (final AppUser user in users) {
      if (user.email.trim().toLowerCase() == normalizedEmail &&
          user.password == password) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null) {
      return 'Invalid email or password.';
    }

    await _sessionBox.put(_currentUserIdKey, matchedUser.id);

    return null;
  }

  static Future<void> logout() async {
    await init();

    await _sessionBox.delete(_currentUserIdKey);
  }

  static AppUser? getCurrentUser() {
    if (!Hive.isBoxOpen(_usersBoxName) || !Hive.isBoxOpen(_sessionBoxName)) {
      return null;
    }

    final dynamic currentUserId = _sessionBox.get(_currentUserIdKey);

    if (currentUserId == null) {
      return null;
    }

    final String userId = currentUserId.toString();

    final List<AppUser> users = getAllUsers();

    for (final AppUser user in users) {
      if (user.id == userId) {
        return user;
      }
    }

    return null;
  }

  static bool get isLoggedIn {
    return getCurrentUser() != null;
  }

  static String? get currentUserId {
    final AppUser? user = getCurrentUser();

    return user?.id;
  }

  static Future<void> _saveUsers(List<AppUser> users) async {
    await _usersBox.put(_usersKey, users.map((user) => user.toMap()).toList());
  }
}
