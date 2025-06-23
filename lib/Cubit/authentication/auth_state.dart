import 'package:sa7el/Model/admin_model.dart';

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
