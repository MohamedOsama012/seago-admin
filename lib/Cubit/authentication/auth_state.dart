import 'package:sa7el/Model/admin_model.dart';
import 'package:sa7el/Model/user_model.dart';

abstract class AuthenticationStates {}

class AuthenticationLoginStateInitial extends AuthenticationStates {}

class AuthenticationLoginStatesuccess extends AuthenticationStates {
  final AdminModel? adminModel;
  AuthenticationLoginStatesuccess(this.adminModel);
}

class AuthenticationLoginStateFailed extends AuthenticationStates {
  final String errMessage;
  AuthenticationLoginStateFailed(this.errMessage);
}

class AuthenticationLoginStateLoading extends AuthenticationStates {}

class AuthenticationLogoutState extends AuthenticationStates {}

class AuthenticationUserModel extends AuthenticationStates {
  final UserModel? userModel;
  AuthenticationUserModel(this.userModel);
}
