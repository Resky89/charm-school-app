import 'package:flutter/foundation.dart';
import '../controller/login_controller.dart';

class UserProvider extends ChangeNotifier {
  UserType? _userType;

  UserType? get userType => _userType;

  void setUserType(UserType? type) {
    _userType = type;
    notifyListeners();
  }

  bool get isPetugas => _userType == UserType.petugas;
  bool get isUser => _userType == UserType.user;
}
