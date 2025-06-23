import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';

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
      print('Edit Village Error: ${error.toString()}');
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
  void addVillage({
    required String name,
    required String location,
    required String description,
    String? arName,
    String? arDescription,
    required int zoneId,
    required int status,
    String? imagePath,
  }) {
    emit(VillageAddLoadingState());

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
      url: WegoEndPoints.addVillagesEndPoint,
      data: data,
      token: token,
    ).then((value) {
      emit(VillageAddSuccessState());
      getData(); // Refresh the villages list after successful addition
    }).catchError((error) {
      print('Add Village Error: ${error.toString()}');
      emit(VillageAddErrorState(error.toString()));
    });
  }

  @override
  Future<void> addData(Villages item) {
    // TODO: implement addData
    throw UnimplementedError();
  }

  @override
  Future<void> editData(Villages item) {
    // TODO: implement editData
    throw UnimplementedError();
  }
}
