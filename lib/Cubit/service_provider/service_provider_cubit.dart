import 'dart:developer';

import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';

class ServiceProviderCubit
    extends EntityCubit<ServiceProviderModel, ServiceProviderStates> {
  ServiceProviderCubit() : super(ServiceProviderInitialState());

  final token = CacheHelper.getData(key: 'token');

  @override
  List<ServiceProviderModel> items = [];

  @override
  Future<void> addData(ServiceProviderModel item) {
    // TODO: implement addData
    throw UnimplementedError();
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
  Future<void> editData(ServiceProviderModel item) {
    // TODO: implement editData
    throw UnimplementedError();
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
        log(items.toString());
        emit(ServiceProviderGetDataSuccessState());
      }
    } catch (e) {
      log(e.toString());
      emit(ServiceProviderGetDataErrorState());
    }
  }
}
