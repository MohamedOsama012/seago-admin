import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/authentication/auth_state.dart';
import 'package:sa7el/Model/admin_model.dart';
import 'package:sa7el/Model/user_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';

class AuthenticationCubit extends Cubit<AuthenticationStates> {
  AuthenticationCubit() : super(AuthenticationLoginStateInitial());

  AdminModel? _adminModel;

  AdminModel? get adminModel => _adminModel;

  /// Logs in an admin using provided credentials.
  Future<void> adminLogin({
    required String email,
    required String password,
  }) async {
    emit(AuthenticationLoginStateLoading());

    try {
      final Response response = await DioHelper.postData(
        url: WegoEndPoints.loginEndPoint,
        data: {"email": email, "password": password},
      );

      // Parse and cache admin data
      _adminModel = AdminModel.fromJson(response.data);
      await CacheHelper.saveData(key: 'token', value: _adminModel?.token);

      if (kDebugMode) {
        print('Login success. Token: ${_adminModel?.token}');
      }

      emit(AuthenticationLoginStatesuccess(_adminModel));
    } on DioException catch (dioError) {
      emit(AuthenticationLoginStateFailed(_handleDioError(dioError)));
      print(dioError.toString());
    } catch (error) {
      emit(
        AuthenticationLoginStateFailed('Unexpected error: ${error.toString()}'),
      );
    }
  }

  /// Logs the user out by calling the API and clearing the state.
  Future<void> logout() async {
    emit(AuthenticationLoginStateLoading());

    try {
      final token = CacheHelper.getData(key: 'token');

      // Call the logout API endpoint
      await DioHelper.getData(
        url: WegoEndPoints.logoutEndPoint,
        token: token,
      );

      // Clear local data after successful API call
      _adminModel = null;
      userModel = null;
      await CacheHelper.removeData(key: 'token');

      emit(AuthenticationLogoutState());
    } on DioException catch (dioError) {
      // Even if API call fails, clear local data for security
      _adminModel = null;
      userModel = null;
      await CacheHelper.removeData(key: 'token');

      emit(AuthenticationLogoutState());

      if (kDebugMode) {
        print('Logout API error: ${_handleDioError(dioError)}');
      }
    } catch (error) {
      // Even if API call fails, clear local data for security
      _adminModel = null;
      userModel = null;
      await CacheHelper.removeData(key: 'token');

      emit(AuthenticationLogoutState());

      if (kDebugMode) {
        print('Logout unexpected error: ${error.toString()}');
      }
    }
  }

  /// Handles various Dio exceptions and maps them to readable messages.
  String _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 401:
      case 403:
        return 'Wrong email or password';
      case 422:
        return 'Invalid input data';
      case 429:
        return 'Too many attempts. Please try again later';
      case 500:
        return 'Server error. Please try again later';
    }

    // Handle Dio-specific errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Unexpected response format.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unknown network error occurred.';
    }
  }

  UserModel? userModel;

  void getAdminData() async {
    final token = CacheHelper.getData(key: 'token');
    DioHelper.getData(
      url: WegoEndPoints.adminDataEndPoint,
      token: token,
    ).then((value) {
      userModel = UserModel.fromJson(value.data['user']);
      log(userModel!.name.toString());
      emit(AuthenticationUserModel(userModel));
    }).catchError((error) {
      log(error.toString());
      emit(AuthenticationLoginStateFailed(error.toString()));
    });
  }
}
