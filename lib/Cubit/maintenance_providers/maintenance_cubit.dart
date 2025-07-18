import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_state.dart';
import 'package:sa7el/Model/maintenance_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';
import 'dart:developer';

import 'package:sa7el/views/Home/Widgets/add_dialog_widget.dart';
import 'package:dio/dio.dart';

class MaintenanceCubit extends EntityCubit<Providers, MaintenanceStates> {
  MaintenanceCubit() : super(MaintenanceLoadingState());

  static MaintenanceCubit get(context) => BlocProvider.of(context);

  MaintenanceModel? maintenanceModel;
  @override
  List<Providers> items = [];
  List<Providers> filteredProviders = [];
  List<MaintenanceTypes> maintenanceTypes = [];
  List<Villages> villages = [];

  final token = CacheHelper.getData(key: 'token');

  ///get all maintenance data
  @override
  Future<void> getData() async {
    emit(MaintenanceLoadingState());

    DioHelper.getData(url: WegoEndPoints.maintenanceEndPoint, token: token)
        .then((value) {
      maintenanceModel = MaintenanceModel.fromJson(value.data);

      items = maintenanceModel?.providers ?? [];
      maintenanceTypes = maintenanceModel?.maintenanceTypes ?? [];
      villages = maintenanceModel?.villages ?? [];
      filteredProviders = List.from(items);

      emit(MaintenanceSuccessState(items, maintenanceTypes, villages));
    }).catchError((error) {
      print(error.toString());
      emit(MaintenanceErrorState(error.toString()));
    });
  }

  ///filter providers by maintenance type
  void filterProvidersByType(num? maintenanceTypeId) {
    if (maintenanceTypeId == null) {
      filteredProviders = List.from(items);
    } else {
      filteredProviders = items
          .where((provider) => provider.maintenanceTypeId == maintenanceTypeId)
          .toList();
    }

    emit(MaintenanceFilteredState(
        filteredProviders, maintenanceTypes, villages));
  }

  ///filter providers by village
  void filterProvidersByVillage(num? villageId) {
    if (villageId == null) {
      filteredProviders = List.from(items);
    } else {
      filteredProviders =
          items.where((provider) => provider.villageId == villageId).toList();
    }

    emit(MaintenanceFilteredState(
        filteredProviders, maintenanceTypes, villages));
  }

  ///clear filter
  void clearFilter() {
    filteredProviders = List.from(items);

    emit(
        MaintenanceSuccessState(filteredProviders, maintenanceTypes, villages));
  }

  ///search providers
  void searchProviders(String searchText) {
    if (searchText.isEmpty) {
      filteredProviders = List.from(items);
    } else {
      filteredProviders = items.where((provider) {
        final name = provider.name?.toLowerCase() ?? '';
        final arName = provider.arName?.toString().toLowerCase() ?? '';
        final description = provider.description?.toLowerCase() ?? '';
        final searchLower = searchText.toLowerCase();

        return name.contains(searchLower) ||
            arName.contains(searchLower) ||
            description.contains(searchLower);
      }).toList();
    }

    emit(MaintenanceSearchState(filteredProviders, maintenanceTypes, villages));
  }

  ///get maintenance type by id
  MaintenanceTypes? getMaintenanceTypeById(num? maintenanceTypeId) {
    if (maintenanceTypeId == null) return null;
    try {
      return maintenanceTypes
          .firstWhere((type) => type.id == maintenanceTypeId);
    } catch (e) {
      return null;
    }
  }

  ///get village by id
  Villages? getVillageById(num? villageId) {
    if (villageId == null) return null;
    try {
      return villages.firstWhere((village) => village.id == villageId);
    } catch (e) {
      return null;
    }
  }

  ///get providers count by maintenance type
  Map<num, int> getProvidersCountByType() {
    Map<num, int> typeCount = {};

    for (var provider in items) {
      if (provider.maintenanceTypeId != null) {
        typeCount[provider.maintenanceTypeId!] =
            (typeCount[provider.maintenanceTypeId!] ?? 0) + 1;
      }
    }

    return typeCount;
  }

  ///edit provider
  void editProvider({
    required int providerId,
    required String name,
    required String phone,
    required String location,
    required String description,
    String? arName,
    String? arDescription,
    required int maintenanceTypeId,
    int? villageId,
    required int status,
    String? openFrom,
    String? openTo,
    String? imagePath,
  }) {
    emit(MaintenanceEditLoadingState());

    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'location': location,
      'description': description,
      'ar_name': arName,
      'ar_description': arDescription,
      'maintenance_type_id': maintenanceTypeId,
      'village_id': villageId,
      'status': status,
      'open_from': openFrom,
      'open_to': openTo,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      data['image'] = imagePath;
    }

    DioHelper.postData(
      url: '${WegoEndPoints.updateProviderEndPoint}/$providerId',
      data: data,
      token: token,
    ).then((value) {
      emit(MaintenanceEditSuccessState());
      getData();
    }).catchError((error) {
      print('Edit Provider Error: ${error.toString()}');
      emit(MaintenanceEditErrorState(error.toString()));
    });
  }

  ///delete provider
  @override
  Future<void> deleteData(int providerId) async {
    emit(MaintenanceDeleteLoadingState());

    DioHelper.deleteData(
      url: '${WegoEndPoints.deleteProviderEndPoint}/$providerId',
      token: token,
    ).then((value) {
      emit(MaintenanceDeleteSuccessState());
      getData();
    }).catchError((error) {
      print('Delete Provider Error: ${error.toString()}');
      emit(MaintenanceDeleteErrorState(error.toString()));
    });
  }

  @override
  Future<void> addData(dynamic addModel) async {
    if (addModel is! MaintenanceProviderAddModel) {
      emit(MaintenanceAddErrorState(
          "Invalid model type for adding a maintenance provider."));
      return;
    }

    emit(MaintenanceAddLoadingState());

    try {
      final apiData = addModel.toApiData();

      final response = await DioHelper.postData(
        url: WegoEndPoints.addProviderEndPoint,
        data: apiData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(MaintenanceAddSuccessState());
        await getData(); // Refresh list
      } else {
        emit(MaintenanceAddErrorState(
            "Failed to add maintenance provider: ${response.statusMessage}"));
      }
    } catch (error) {
      log('Add Maintenance Provider Error: ${error.toString()}');
      if (error is DioException) {
        log('Dio Error Response: ${error.response?.data}');
      }
      emit(MaintenanceAddErrorState(error.toString()));
    }
  }

  @override
  Future<void> editData(dynamic editModel) async {
    emit(MaintenanceEditLoadingState());

    try {
      // Get all the data from the complete model (including base64 image if present)
      final allData = editModel.toApiData();

      log('Updating maintenance provider ${editModel.maintenanceProviderId} with complete data: ${allData.keys.toList()}');

      final response = await DioHelper.postData(
        url:
            "${WegoEndPoints.updateProviderEndPoint}/${editModel.maintenanceProviderId}",
        data: allData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(MaintenanceEditSuccessState());
        // Refresh the data after successful update
        getData();
      } else {
        emit(
            MaintenanceEditErrorState("Failed to update maintenance provider"));
      }
    } catch (error) {
      print('Edit Maintenance Provider Error: ${error.toString()}');
      emit(MaintenanceEditErrorState(error.toString()));
    }
  }
}
