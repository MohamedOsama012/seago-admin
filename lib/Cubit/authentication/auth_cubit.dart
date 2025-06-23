import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/authentication/auth_state.dart';
import 'package:sa7el/Model/admin_model.dart';
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

  /// Logs the user out by clearing the state.
  void logout() {
    _adminModel = null;
    CacheHelper.removeData(key: 'token');
    emit(AuthenticationLoginStateInitial());
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
}
