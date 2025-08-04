
import 'package:flutter/foundation.dart';
import 'package:insta/fire_base_services/Auth.dart';
import 'package:insta/models/user.dart';
import 'package:provider/provider.dart';


class UserProvider with ChangeNotifier {
  UserData? _userData;
  UserData? get getUser => _userData;
  
  refreshUser() async {
    UserData userData = await Auth().getUserDetails();
    _userData = userData;
    notifyListeners();
  }
 }
 
 class AuthMethods {
 }