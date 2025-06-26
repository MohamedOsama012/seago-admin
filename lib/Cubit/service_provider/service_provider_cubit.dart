import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';
import 'package:sa7el/views/Home/Widgets/add_dialog_widget.dart';

class ServiceProviderCubit
    extends EntityCubit<ServiceProviderModel, ServiceProviderStates> {
  ServiceProviderCubit() : super(ServiceProviderInitialState());

  final token = CacheHelper.getData(key: 'token');

  @override
  List<ServiceProviderModel> items = [];

  @override
  Future<void> addData(dynamic addModel) async {
    if (addModel is! ServiceProviderAddModel) {
      emit(ServiceProviderAddFailedState(
          "Invalid model type for adding a service provider."));
      return;
    }

    emit(ServiceProviderAddLoadingState());

    try {
      final apiData = addModel.toApiData();

      final response = await DioHelper.postData(
        url: WegoEndPoints.addServiceProviderEndPoint,
        data: apiData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ServiceProviderAddSuccessState(
            "Service Provider added successfully."));
        await getData(); // Refresh list
      } else {
        emit(ServiceProviderAddFailedState(
            "Failed to add Service Provider: ${response.statusMessage}"));
      }
    } catch (error) {
      log('Add Service Provider Error: ${error.toString()}');
      if (error is DioException) {
        log('Dio Error Response: ${error.response?.data}');
      }
      emit(ServiceProviderAddFailedState(error.toString()));
    }
  }

  @override
  Future<void> deleteData(int serviceProviderId) async {
    emit(ServiceProviderGetDataLoadingState());

    try {
      await DioHelper.deleteData(
        url:
            '${WegoEndPoints.deleteServiceProviderEndPoint}/$serviceProviderId',
        token: token,
      );
      emit(ServiceProviderDeleteSuccessState(
          "Service Provider deleted successfully"));
      await getData();
    } catch (error) {
      print('Delete Mall Error: ${error.toString()}');
      emit(ServiceProviderDeleteFailedState(error.toString()));
    }
  }

  @override
  Future<void> editData(dynamic editModel) async {
    emit(ServiceProviderGetDataLoadingState());

    try {
      // Get all the data from the complete model (including base64 image if present)
      final allData = editModel.toApiData();

      log('Updating service provider ${editModel.serviceProviderId} with complete data: ${allData.keys.toList()}');

      final response = await DioHelper.postData(
        url:
            "${WegoEndPoints.updateServiceProviderEndPoint}/${editModel.serviceProviderId}",
        data: allData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(ServiceProviderEditSuccessState(
            "Service Provider Successfully Updated"));
        // Refresh the data after successful update
        await getData();
      } else {
        emit(ServiceProviderEditFailedState(
            "Failed to update service provider"));
      }
    } catch (error) {
      if (error is DioException && error.response != null) {
        print(
            'Edit Service Provider Error Response Data: ${error.response?.data}');
      } else {
        print('Edit Service Provider Error: ${error.toString()}');
      }
      emit(ServiceProviderEditFailedState(error.toString()));
    }
  }

  @override
  Future<void> getData() async {
    emit(ServiceProviderGetDataLoadingState());
    try {
      final response = await DioHelper.getData(
        url: WegoEndPoints.getServiceProviderEndPoint,
        token: token,
      );
      if (response.statusCode == 200) {
        items = (response.data['providers'] as List)
            .map(
                (e) => ServiceProviderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(ServiceProviderGetDataSuccessState());
      }
    } catch (e) {
      log(e.toString());
      emit(ServiceProviderGetDataErrorState());
    }
  }
}
