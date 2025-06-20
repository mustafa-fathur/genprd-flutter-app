import 'package:flutter/foundation.dart';
import 'package:genprd/features/user/models/user_model.dart';
import 'package:genprd/features/user/services/user_service.dart';

enum UserProfileStatus { initial, loading, loaded, error }

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  // State variables
  UserProfileStatus _status = UserProfileStatus.initial;
  User? _user;
  String? _errorMessage;

  // Getters
  UserProfileStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoaded => _status == UserProfileStatus.loaded;

  // Format member since date
  String get memberSince {
    debugPrint('User in provider: $_user');
    debugPrint('User created_at: ${_user?.createdAt}');

    if (_user?.createdAt == null) return 'Unknown';
    return _userService.formatMemberSince(_user!.createdAt);
  }

  // Get user profile
  Future<void> getUserProfile() async {
    if (_status == UserProfileStatus.loading) return;

    try {
      _status = UserProfileStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final user = await _userService.getUserProfile();

      if (user != null) {
        _user = user;
        _status = UserProfileStatus.loaded;
        debugPrint('User profile loaded: ${user.name}');
      } else {
        _status = UserProfileStatus.error;
        _errorMessage = 'Failed to load user profile';
      }
    } catch (e) {
      _status = UserProfileStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error loading user profile: $e');
    }

    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile({String? name, String? email}) async {
    if (_status == UserProfileStatus.loading) return;

    try {
      _status = UserProfileStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final updatedUser = await _userService.updateUserProfile(
        name: name,
        email: email,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        _status = UserProfileStatus.loaded;
        debugPrint('User profile updated: ${updatedUser.name}');
      } else {
        _status = UserProfileStatus.error;
        _errorMessage = 'Failed to update user profile';
      }
    } catch (e) {
      _status = UserProfileStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error updating user profile: $e');
    }

    notifyListeners();
  }

  // Set user from auth provider
  void setUser(User? user) {
    _user = user;
    _status =
        user == null ? UserProfileStatus.initial : UserProfileStatus.loaded;
    notifyListeners();
  }

  // Clear user data and reset status
  void clearUser() {
    _user = null;
    _status = UserProfileStatus.initial;
    notifyListeners();
  }
}
