// lib/core/services/remember_me_service.dart
class RememberMeService {
  static final RememberMeService _instance = RememberMeService._internal();
  factory RememberMeService() => _instance;
  RememberMeService._internal();

  bool _rememberMe = false;

  bool get rememberMe => _rememberMe;

  void setRememberMe(bool value) {
    _rememberMe = value;
  }

  void reset() {
    _rememberMe = false;
  }
}
