import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Cubit/maintenance_providers/maintenance_state.dart';
import 'package:sa7el/Model/maintenance_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';

class MaintenanceCubit extends Cubit<MaintenanceStates> {
  MaintenanceCubit() : super(MaintenanceLoadingState());

  static MaintenanceCubit get(context) => BlocProvider.of(context);

  MaintenanceModel? maintenanceModel;
  List<Providers> allProviders = [];
  List<Providers> filteredProviders = [];
  List<MaintenanceTypes> maintenanceTypes = [];
  List<Villages> villages = [];

  final token = CacheHelper.getData(key: 'token');

  ///get all maintenance data
  void getMaintenanceData() {
    emit(MaintenanceLoadingState());

    DioHelper.getData(url: WegoEndPoints.maintenanceEndPoint, token: token)
        .then((value) {
      maintenanceModel = MaintenanceModel.fromJson(value.data);

      allProviders = maintenanceModel?.providers ?? [];
      maintenanceTypes = maintenanceModel?.maintenanceTypes ?? [];
      villages = maintenanceModel?.villages ?? [];
      filteredProviders = List.from(allProviders);

      emit(MaintenanceSuccessState(allProviders, maintenanceTypes, villages));
    }).catchError((error) {
      print(error.toString());
      emit(MaintenanceErrorState(error.toString()));
    });
  }

  ///filter providers by maintenance type
  void filterProvidersByType(num? maintenanceTypeId) {
    if (maintenanceTypeId == null) {
      filteredProviders = List.from(allProviders);
    } else {
      filteredProviders = allProviders.where((provider) =>
      provider.maintenanceTypeId == maintenanceTypeId).toList();
    }

    MaintenanceModel filteredModel = MaintenanceModel(
      providers: filteredProviders,
      maintenanceTypes: maintenanceTypes,
      villages: villages,
    );

    emit(MaintenanceFilteredState(filteredProviders, maintenanceTypes, villages));
  }

  ///filter providers by village
  void filterProvidersByVillage(num? villageId) {
    if (villageId == null) {
      filteredProviders = List.from(allProviders);
    } else {
      filteredProviders = allProviders.where((provider) =>
      provider.villageId == villageId).toList();
    }

    MaintenanceModel filteredModel = MaintenanceModel(
      providers: filteredProviders,
      maintenanceTypes: maintenanceTypes,
      villages: villages,
    );

    emit(MaintenanceFilteredState(filteredProviders, maintenanceTypes, villages));
  }

  ///clear filter
  void clearFilter() {
    filteredProviders = List.from(allProviders);

    MaintenanceModel resetModel = MaintenanceModel(
      providers: filteredProviders,
      maintenanceTypes: maintenanceTypes,
      villages: villages,
    );

    emit(MaintenanceSuccessState(filteredProviders, maintenanceTypes, villages));
  }

  ///search providers
  void searchProviders(String searchText) {
    if (searchText.isEmpty) {
      filteredProviders = List.from(allProviders);
    } else {
      filteredProviders = allProviders.where((provider) {
        final name = provider.name?.toLowerCase() ?? '';
        final arName = provider.arName?.toString().toLowerCase() ?? '';
        final description = provider.description?.toLowerCase() ?? '';
        final searchLower = searchText.toLowerCase();

        return name.contains(searchLower) ||
            arName.contains(searchLower) ||
            description.contains(searchLower);
      }).toList();
    }

    MaintenanceModel searchModel = MaintenanceModel(
      providers: filteredProviders,
      maintenanceTypes: maintenanceTypes,
      villages: villages,
    );

    emit(MaintenanceSearchState(filteredProviders, maintenanceTypes, villages));
  }

  ///get maintenance type by id
  MaintenanceTypes? getMaintenanceTypeById(num? maintenanceTypeId) {
    if (maintenanceTypeId == null) return null;
    try {
      return maintenanceTypes.firstWhere((type) => type.id == maintenanceTypeId);
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

    for (var provider in allProviders) {
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
      getMaintenanceData();
    }).catchError((error) {
      print('Edit Provider Error: ${error.toString()}');
      emit(MaintenanceEditErrorState(error.toString()));
    });
  }

  ///delete provider
  void deleteProvider(int providerId) {
    emit(MaintenanceDeleteLoadingState());

    DioHelper.deleteData(
      url: '${WegoEndPoints.deleteProviderEndPoint}/$providerId',
      token: token,
    ).then((value) {
      emit(MaintenanceDeleteSuccessState());
      getMaintenanceData();
    }).catchError((error) {
      print('Delete Provider Error: ${error.toString()}');
      emit(MaintenanceDeleteErrorState(error.toString()));
    });
  }

  ///add new provider
  void addProvider({
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
    emit(MaintenanceAddLoadingState());

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
      url: WegoEndPoints.addProviderEndPoint,
      data: data,
      token: token,
    ).then((value) {
      emit(MaintenanceAddSuccessState());
      getMaintenanceData(); // Refresh the data after successful addition
    }).catchError((error) {
      print('Add Provider Error: ${error.toString()}');
      emit(MaintenanceAddErrorState(error.toString()));
    });
  }
}