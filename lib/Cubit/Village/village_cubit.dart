import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';
import 'dart:developer';

import 'package:sa7el/views/Home/Widgets/add_dialog_widget.dart';

class VillageCubit extends EntityCubit<Villages, VillageStates> {
  VillageCubit() : super(VillaLoadingState());

  static VillageCubit get(context) => BlocProvider.of(context);

  VillageModel? villageModel;
  @override
  List<Villages> items = [];
  List<Villages> filteredVillages = [];
  List<Zones> zones = [];

  final token = CacheHelper.getData(key: 'token');

  ///get all villages
  @override
  Future<void> getData() async {
    emit(VillaLoadingState());

    DioHelper.getData(url: WegoEndPoints.villagesEndPoint, token: token)
        .then((value) {
      villageModel = VillageModel.fromJson(value.data);

      items = villageModel?.villages ?? [];
      zones = villageModel?.zones ?? [];
      filteredVillages = List.from(items);

      emit(VillageSuccessState(filteredVillages, zones));
    }).catchError((error) {
      print(error.toString());
      emit(VillageErrorState(error.toString()));
    });
  }

  ///filter villages by zone
  void filterVillagesByZone(num? zoneId) {
    if (zoneId == null) {
      filteredVillages = List.from(items);
    } else {
      filteredVillages =
          items.where((village) => village.zoneId == zoneId).toList();
    }

    emit(VillageFilteredState(filteredVillages, zones));
  }

  ///clear filter
  void clearFilter() {
    filteredVillages = List.from(items);
    emit(VillageSuccessState(filteredVillages, zones));
  }

  ///search villages
  void searchVillages(String searchText) {
    if (searchText.isEmpty) {
      filteredVillages = List.from(items);
    } else {
      filteredVillages = items.where((village) {
        final name = village.name?.toLowerCase() ?? '';
        final arName = village.arName?.toString().toLowerCase() ?? '';
        final searchLower = searchText.toLowerCase();

        return name.contains(searchLower) || arName.contains(searchLower);
      }).toList();
    }

    emit(VillageSearchState(filteredVillages, zones));
  }

  ///get zone by id
  Zones? getZoneById(num? zoneId) {
    if (zoneId == null) return null;
    try {
      return zones.firstWhere((zone) => zone.id == zoneId);
    } catch (e) {
      return null;
    }
  }

  ///get villages count by zone
  Map<num, int> getVillagesCountByZone() {
    Map<num, int> zoneCount = {};

    for (var village in items) {
      if (village.zoneId != null) {
        zoneCount[village.zoneId!] = (zoneCount[village.zoneId!] ?? 0) + 1;
      }
    }

    return zoneCount;
  }

  ///edit village
  void editVillage({
    required int villageId,
    required String name,
    required String location,
    required String description,
    String? arName,
    String? arDescription,
    required int zoneId,
    required int status,
    String? imagePath,
  }) {
    emit(VillageEditLoadingState());

    Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'description': description,
      'ar_name': arName,
      'ar_description': arDescription,
      'zone_id': zoneId,
      'status': status,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      data['image'] = imagePath;
    }

    DioHelper.postData(
      url: '${WegoEndPoints.UpdateVillagesEndPoint}/$villageId',
      data: data,
      token: token,
    ).then((value) {
      emit(VillageEditSuccessState());
      getData();
    }).catchError((error) {
      print('Edit Village Error: ${error.response?.data.toString()}');
      emit(VillageEditErrorState(error.toString()));
    });
  }

  ///delete village
  @override
  Future<void> deleteData(int villageId) async {
    emit(VillageDeleteLoadingState());

    DioHelper.deleteData(
      url: '${WegoEndPoints.deleteVillagesEndPoint}/$villageId',
      token: token,
    ).then((value) {
      emit(VillageDeleteSuccessState());
      getData();
    }).catchError((error) {
      print('Delete Village Error: ${error.toString()}');
      emit(VillageDeleteErrorState(error.toString()));
    });
  }

  ///add new village
  @override
  Future<void> addData(dynamic addModel) async {
    if (addModel is! VillageAddModel) {
      emit(VillageAddErrorState("Invalid model type for adding a village."));
      return;
    }

    emit(VillageAddLoadingState());

    try {
      final apiData = addModel.toApiData();

      final response = await DioHelper.postData(
        url: WegoEndPoints.addVillagesEndPoint,
        data: apiData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(VillageAddSuccessState());
        await getData(); // Refresh list
      } else {
        emit(VillageAddErrorState(
            "Failed to add village: ${response.statusMessage}"));
      }
    } catch (error) {
      log('Add Village Error: ${error.toString()}');
      if (error is DioException) {
        log('Dio Error Response: ${error.response?.data}');
      }
      emit(VillageAddErrorState(error.toString()));
    }
  }

  @override
  Future<void> editData(dynamic editModel) async {
    emit(VillageEditLoadingState());

    try {
      // Get all the data from the complete model (including base64 image if present)
      final allData = editModel.toApiData();

      log('Updating village ${editModel.villageId} with complete data: ${allData.keys.toList()}');

      final response = await DioHelper.postData(
        url: "${WegoEndPoints.UpdateVillagesEndPoint}/${editModel.villageId}",
        data: allData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(VillageEditSuccessState());
        // Refresh the data after successful update
        await getData();
      } else {
        emit(VillageEditErrorState("Failed to update village"));
      }
    } catch (error) {
      if (error is DioException && error.response != null) {
        print('Edit Village Error Response Data: ${error.response?.data}');
      } else {
        print('Edit Village Error: ${error.toString()}');
      }
      emit(VillageEditErrorState(error.toString()));
    }
  }
}
