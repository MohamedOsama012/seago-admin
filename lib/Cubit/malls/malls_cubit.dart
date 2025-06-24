import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sa7el/Cubit/entity/entity_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/controller/dio/dio_helper.dart';
import 'package:sa7el/controller/dio/end_points.dart';
import 'package:sa7el/views/Home/Widgets/add_dialog_widget.dart';

class MallsCubit extends EntityCubit<MallModel, MallsStates> {
  MallsCubit() : super(MallsInitialState());

  static MallsCubit get(context) => BlocProvider.of(context);

  final token = CacheHelper.getData(key: 'token');

  @override
  List<MallModel> items = [];
  List<MallModel> filteredMalls = [];

  @override
  Future<void> getData() async {
    emit(MallsGetDataLoadingState());
    log('token: $token');
    try {
      final response = await DioHelper.getData(
        url: WegoEndPoints.getMallsEndPoint,
        token: token,
      );
      items = (response.data['malls'] as List)
          .map((mall) => MallModel.fromJson(mall))
          .toList();
      filteredMalls = List.from(items); // Initialize filtered list
      emit(MallsGetDataSuccessState());
    } catch (error) {
      log(error.toString());
      emit(MallsGetDataErrorState(_handleError(error)));
    }
  }

  void filterMalls(String query) {
    filteredMalls = items.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase()) ||
          item.description.toLowerCase().contains(query.toLowerCase()) ||
          item.zone.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    emit(MallsGetDataSuccessState());
  }

  void applyAdvancedFilters(List<MallModel> filtered) {
    filteredMalls = filtered;
    emit(MallsGetDataSuccessState());
  }

  void resetFilters() {
    filteredMalls = List.from(items);
    emit(MallsGetDataSuccessState());
  }

  // Future<void> addMall({
  //   required String name,
  //   required int status,
  //   required String zoneName,
  //   required String openFrom,
  //   required String openTo,
  //   String? description,
  //   String? arName,
  //   String? arDescription,
  // }) async {
  //   // Enhanced validation
  //   if (name.trim().isEmpty) {
  //     emit(MallsAddFailedState("Mall name cannot be empty"));
  //     return;
  //   }
  //   if (zoneName.trim().isEmpty) {
  //     emit(MallsAddFailedState("Zone name cannot be empty"));
  //     return;
  //   }
  //   if (openFrom.trim().isEmpty || openTo.trim().isEmpty) {
  //     emit(MallsAddFailedState("Opening hours cannot be empty"));
  //     return;
  //   }

  //   try {
  //     emit(MallsAddLoadingState());

  //     // First, get or create the zone
  //     final zoneId = await _createOrGetZoneId(zoneName);
  //     if (zoneId == null) {
  //       emit(MallsAddFailedState("Failed to create or retrieve zone"));
  //       return;
  //     }

  //     print("Zone ID retrieved: $zoneId");

  //     // Format time properly
  //     String formatTo24Hr(String time) {
  //       try {
  //         String cleanedTime = time.trim().toUpperCase();

  //         // Handle different time formats
  //         if (RegExp(r'^\d{1,2}:\d{2}:\d{2}$').hasMatch(cleanedTime)) {
  //           // Already in HH:MM:SS format
  //           return cleanedTime;
  //         }

  //         if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(cleanedTime)) {
  //           // HH:MM format, add seconds
  //           return "$cleanedTime:00";
  //         }

  //         if (RegExp(r'^\d{1,2}$').hasMatch(cleanedTime)) {
  //           // Just hour, add minutes and seconds
  //           int hour = int.parse(cleanedTime);
  //           return "${hour.toString().padLeft(2, '0')}:00:00";
  //         }

  //         // Handle AM/PM format
  //         if (cleanedTime.contains('AM') || cleanedTime.contains('PM')) {
  //           try {
  //             final inputFormat = DateFormat.jm();
  //             final dateTime = inputFormat.parse(cleanedTime);
  //             return DateFormat("HH:mm:ss").format(dateTime);
  //           } catch (e) {
  //             print("AM/PM parsing error: $e");
  //           }
  //         }

  //         // Fallback: assume it's a valid time string
  //         return cleanedTime;
  //       } catch (e) {
  //         print("Time formatting error for '$time': $e");
  //         return "$time:00"; // Basic fallback
  //       }
  //     }

  //     // Prepare data for API
  //     final data = {
  //       "name": name.trim(),
  //       "status": status,
  //       "zone_id": zoneId,
  //       "open_from": formatTo24Hr(openFrom),
  //       "open_to": formatTo24Hr(openTo),
  //     };

  //     // Add optional fields
  //     if (description != null && description.trim().isNotEmpty) {
  //       data["description"] = description.trim();
  //     } else {
  //       // Provide default description if none given
  //       data["description"] = "Mall in ${zoneName.trim()}";
  //     }

  //     if (arName != null && arName.trim().isNotEmpty) {
  //       data["ar_name"] = arName.trim();
  //     }

  //     if (arDescription != null && arDescription.trim().isNotEmpty) {
  //       data["ar_description"] = arDescription.trim();
  //     }

  //     print("Sending mall data: $data");

  //     // Send request using FormData for better compatibility
  //     FormData formData = FormData();
  //     data.forEach((key, value) {
  //       formData.fields.add(MapEntry(key, value.toString()));
  //     });

  //     final mallResponse = await DioHelper.postData(
  //       url: WegoEndPoints.addMallsEndPoint,
  //       data: formData,
  //       token: token,
  //     );

  //     print("Response status: ${mallResponse.statusCode}");
  //     print("Response data: ${mallResponse.data}");

  //     if (mallResponse.statusCode == 200 || mallResponse.statusCode == 201) {
  //       emit(MallsAddSuccessState("Mall added successfully"));
  //       // Refresh data after successful addition
  //       await getData();
  //     } else {
  //       final errorMessage = _extractErrorMessage(mallResponse.data);
  //       emit(MallsAddFailedState(errorMessage));
  //     }
  //   } catch (error) {
  //     print("Add mall error: $error");
  //     emit(MallsAddFailedState(_handleError(error)));
  //   }
  // }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Check for validation errors
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map<String, dynamic>) {
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.cast<String>());
            } else {
              errorMessages.add(value.toString());
            }
          });
          return errorMessages.join(', ');
        }
      }

      // Check for general message
      if (responseData.containsKey('message')) {
        return responseData['message'].toString();
      }
    }
    return "Failed to add mall";
  }

  // Future<int?> _createOrGetZoneId(String zoneName) async {
  //   try {
  //     print("Getting/creating zone: $zoneName");

  //     // First, try to get existing zones
  //     final getZonesResponse = await DioHelper.getData(
  //       url: WegoEndPoints.getZonesEndPoint,
  //       token: token,
  //     );

  //     print("Get zones response: ${getZonesResponse.statusCode}");
  //     print("Get zones data: ${getZonesResponse.data}");

  //     if (getZonesResponse.statusCode == 200 && getZonesResponse.data != null) {
  //       // Try different possible response structures
  //       List<dynamic> zones = [];

  //       if (getZonesResponse.data is Map<String, dynamic>) {
  //         final responseMap = getZonesResponse.data as Map<String, dynamic>;
  //         zones = responseMap['data'] ??
  //             responseMap['zones'] ??
  //             responseMap['zone'] ??
  //             [];
  //       } else if (getZonesResponse.data is List) {
  //         zones = getZonesResponse.data;
  //       }

  //       print("Found zones: $zones");

  //       // Look for existing zone
  //       for (var zone in zones) {
  //         if (zone is Map<String, dynamic> && zone['name'] != null) {
  //           if (zone['name'].toString().toLowerCase().trim() ==
  //               zoneName.toLowerCase().trim()) {
  //             final id = zone['id'];
  //             print("Found existing zone with ID: $id");
  //             return id is int ? id : int.tryParse(id.toString());
  //           }
  //         }
  //       }
  //     }

  //     // If zone doesn't exist, create it
  //     print("Zone not found, creating new zone: $zoneName");

  //     final createZoneData = {
  //       "name": zoneName.trim(),
  //       "status": 1,
  //     };

  //     print("Creating zone with data: $createZoneData");

  //     final zoneResponse = await DioHelper.postData(
  //       url: WegoEndPoints.addZoneMallsEndPoint,
  //       data: FormData.fromMap(createZoneData), // Use FormData for consistency
  //       token: token,
  //     );

  //     print("Create zone response status: ${zoneResponse.statusCode}");
  //     print("Create zone response data: ${zoneResponse.data}");

  //     if ((zoneResponse.statusCode == 200 || zoneResponse.statusCode == 201)) {
  //       if (zoneResponse.data is Map<String, dynamic>) {
  //         final responseData = zoneResponse.data as Map<String, dynamic>;

  //         // Try different possible response structures for the new zone ID
  //         final id = responseData['data']?['id'] ??
  //             responseData['zone']?['id'] ??
  //             responseData['id'] ??
  //             responseData['data']?['zone']?['id'];

  //         print("Created zone with ID: $id");
  //         return id is int ? id : int.tryParse(id.toString());
  //       }
  //     } else {
  //       print("Failed to create zone. Response: ${zoneResponse.data}");
  //     }
  //   } catch (e) {
  //     print("Error in _createOrGetZoneId: $e");
  //     if (e is DioException) {
  //       print("DioException details: ${e.response?.data}");
  //     }
  //   }
  //   return null;
  // }

  String _handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return "Invalid response format: ${error.message}";
    } else {
      return "Unexpected error: ${error.toString()}";
    }
  }

  String _handleDioError(DioException dioError) {
    String errorMessage = "Something went wrong";

    if (dioError.response != null) {
      final responseData = dioError.response?.data;
      print("DioError response data: $responseData");

      if (responseData is Map<String, dynamic>) {
        // Handle validation errors specifically
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is Map<String, dynamic>) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              } else {
                errorMessages.add("$key: ${value.toString()}");
              }
            });
            return "Validation errors: ${errorMessages.join(', ')}";
          }
        }

        errorMessage = responseData['message'] ??
            dioError.response?.statusMessage ??
            "Unknown error from server";
      } else {
        errorMessage =
            dioError.response?.statusMessage ?? "Unknown server error";
      }

      switch (dioError.response?.statusCode) {
        case 400:
          errorMessage = "Bad request: $errorMessage";
          break;
        case 401:
          errorMessage = "Authentication failed. Please login again.";
          break;
        case 403:
          errorMessage = "Access denied. You don't have permission.";
          break;
        case 422:
          errorMessage = "Validation error: $errorMessage";
          break;
        case 500:
          errorMessage = "Server error. Please try again later.";
          break;
      }
    } else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage =
              "Connection timeout. Please check your internet connection.";
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = "Request timeout. Please try again.";
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = "Server response timeout. Please try again.";
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              "Connection error. Please check your internet connection.";
          break;
        case DioExceptionType.badCertificate:
          errorMessage = "Security certificate error. Please contact support.";
          break;
        case DioExceptionType.cancel:
          errorMessage = "Request was cancelled.";
          break;
        case DioExceptionType.unknown:
          errorMessage = "Network error. Please check your connection.";
          break;
        case DioExceptionType.badResponse:
          errorMessage = "Invalid server response.";
          break;
      }
    }
    return errorMessage;
  }

  void searchMalls(String query) {
    filterMalls(query);
    emit(MallsGetDataSuccessState());
  }

  Future<void> addMall({
    required String name,
    required int status,
    required String zoneName,
    required String openFrom,
    required String openTo,
  }) async {
    if (name.trim().isEmpty) {
      emit(MallsAddFailedState("Mall name cannot be empty"));
      return;
    }
    if (zoneName.trim().isEmpty) {
      emit(MallsAddFailedState("Zone name cannot be empty"));
      return;
    }
    if (openFrom.trim().isEmpty || openTo.trim().isEmpty) {
      emit(MallsAddFailedState("Opening hours cannot be empty"));
      return;
    }
    try {
      emit(MallsAddLoadingState());
      final zoneId = await _createOrGetZoneId(zoneName);
      if (zoneId == null) {
        emit(MallsAddFailedState("Failed to create or retrieve zone"));
        return;
      }
      String formatTo24Hr(String time) {
        try {
          String cleanedTime = time.trim();

          // If input is just an hour like "9", "13", or even "09"
          if (RegExp(r'^\d{1,2}$').hasMatch(cleanedTime)) {
            return "$cleanedTime:00:00";
          }

          // If input is like "9:00" → append seconds
          if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(cleanedTime)) {
            return "$cleanedTime:00";
          }

          // If input is like "9 AM" or "9:00 AM"
          final inputFormat = DateFormat.jm(); // expects 12-hour format
          final dateTime = inputFormat.parse(cleanedTime);
          return DateFormat("H:mm:ss").format(dateTime);
        } catch (e) {
          print("Invalid time input: $time");
          return "0:00:00"; // fallback
        }
      }

      final data = {
        "name": name.trim(),
        "status": status,
        "zone_id": zoneId,
        "open_from": formatTo24Hr(openFrom),
        "open_to": formatTo24Hr(openTo)
      };

      print("Sending mall data: $data");
      print("${formatTo24Hr(openTo)}");

      final mallResponse = await DioHelper.postData(
        url: WegoEndPoints.addMallsEndPoint,
        data: data,
        token: token,
      );
      print(data);
      if (mallResponse.statusCode == 200 || mallResponse.statusCode == 201) {
        emit(MallsAddSuccessState("Mall added successfully"));
        // حديث البيانات فورًا بعد الإضافة الناجحة
        await getData();
      } else {
        print("Response: ${mallResponse.data}");
        emit(MallsAddFailedState("Failed to add mall"));
      }
    } catch (error) {
      emit(MallsAddFailedState(_handleError(error)));
    }
  }

  Future<int?> _createOrGetZoneId(String zoneName) async {
    try {
      final getZonesResponse = await DioHelper.getData(
        url: WegoEndPoints.getZonesEndPoint,
        token: token,
      );

      if (getZonesResponse.statusCode == 200 && getZonesResponse.data != null) {
        List<dynamic> zones = getZonesResponse.data['data'] ??
            getZonesResponse.data['zones'] ??
            [];
        var existingZone = zones.firstWhere(
          (zone) =>
              zone['name']?.toString().toLowerCase() == zoneName.toLowerCase(),
          orElse: () => null,
        );
        if (existingZone != null) {
          return existingZone['id'] is int
              ? existingZone['id']
              : int.tryParse(existingZone['id'].toString());
        }
      }

      final zoneResponse = await DioHelper.postData(
        url: WegoEndPoints.addZoneMallsEndPoint,
        data: {
          "name": zoneName.trim(),
          "status": 1,
        },
        token: token,
      );

      if ((zoneResponse.statusCode == 200 || zoneResponse.statusCode == 201) &&
          zoneResponse.data['success'] == true) {
        final id = zoneResponse.data['data']?['id'] ??
            zoneResponse.data['zone']?['id'] ??
            zoneResponse.data['id'];
        return id is int ? id : int.tryParse(id.toString());
      }
    } catch (e) {
      print("Error in _createOrGetZoneId: $e");
    }
    return null;
  }

  @override
  Future<void> deleteData(int mallId) async {
    emit(MallsDeleteLoadingState());

    try {
      await DioHelper.deleteData(
        url: '${WegoEndPoints.deleteMallDataEndPoint}/$mallId',
        token: token,
      );
      emit(MallsDeleteSuccessState("Mall deleted successfully"));
      // Refresh the malls list after successful deletion
      await getData();
    } catch (error) {
      print('Delete Mall Error: ${error.toString()}');
      emit(MallsDeleteFailedState(error.toString()));
    }
  }

  @override
  Future<void> addData(dynamic addModel) async {
    if (addModel is! MallAddModel) {
      emit(MallsAddFailedState("Invalid model type for adding a mall."));
      return;
    }

    emit(MallsAddLoadingState());

    try {
      // Get the data map from the model
      final apiData = addModel.toApiData();

      // Send the request to the add endpoint
      final response = await DioHelper.postData(
        url: WegoEndPoints.addMallsEndPoint,
        data: apiData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getData(); // Refresh the list after adding
        emit(MallsAddSuccessState("Mall added successfully."));
      } else {
        final errorMessage = _extractErrorMessage(response.data);
        emit(MallsAddFailedState(errorMessage));
      }
    } catch (error) {
      emit(MallsAddFailedState(_handleError(error)));
    }
  }

  // @override
  // Future<void> editData(
  //   MallModel item,
  // ) async {
  //   emit(MallsEditLoadingState());

  //   try {
  //     FormData formData = FormData();

  //     formData.fields.addAll([
  //       MapEntry('name', item.name.trim()),
  //       MapEntry('zone_id', item.zone.id.toString()),
  //       MapEntry('status', item.status.toString()),
  //       MapEntry('description', item.description.trim()),
  //       MapEntry('open_from', item.openFrom.trim()),
  //       MapEntry('open_to', item.openTo.trim()),
  //     ]);

  //     // Add optional Arabic fields if provided
  //     if (item.arName != null && item.arName.isNotEmpty) {
  //       formData.fields.add(MapEntry('ar_name', item.arName.trim()));
  //     }

  //     if (item.arDescription != null && item.arDescription.isNotEmpty) {
  //       formData.fields
  //           .add(MapEntry('ar_description', item.arDescription.trim()));
  //     }

  //     // Handle image upload if provided
  //     if (item.imageLink != null && item.imageLink.isNotEmpty) {
  //       File imageFile = File(item.imageLink);
  //       if (await imageFile.exists()) {
  //         String fileName = imageFile.path.split('/').last;
  //         formData.files.add(MapEntry(
  //           'image',
  //           await MultipartFile.fromFile(
  //             imageFile.path,
  //             filename: fileName,
  //           ),
  //         ));
  //       }
  //     }

  //     final response = await DioHelper.postData(
  //       url: "${WegoEndPoints.updateMallsEndPoint}/${item.id}",
  //       data: formData,
  //       token: token,
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       emit(MallsEditSuccessState("Mall Successfully Updated"));
  //       // Refresh the data after successful update
  //       await getData();
  //     } else {
  //       emit(MallsEditFailedState("Failed to update mall"));
  //     }
  //   } catch (error) {
  //     print('Edit Mall Error: ${error.toString()}');
  //     emit(MallsEditFailedState(_handleError(error)));
  //   }
  // }

  // Edit method for complete model data - sends all fields
  @override
  Future<void> editData(dynamic editModel) async {
    emit(MallsEditLoadingState());

    try {
      // Get all the data from the complete model (including base64 image if present)
      final allData = editModel.toApiData();

      print('DEBUG: CUBIT - API data being sent: ${allData.keys.toList()}');
      if (allData.containsKey('image')) {
        print(
            'DEBUG: CUBIT - Image data included, length: ${allData['image']?.length ?? 0}');
      } else {
        print('DEBUG: CUBIT - No image data in API payload');
      }
      print(
          'DEBUG: CUBIT - Full data (excluding image): ${Map.from(allData)..remove('image')}');

      final response = await DioHelper.postData(
        url: "${WegoEndPoints.updateMallsEndPoint}/${editModel.mallId}",
        data: allData,
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(MallsEditSuccessState("Mall Successfully Updated"));
        // Refresh the data after successful update
        await getData();
      } else {
        emit(MallsEditFailedState("Failed to update mall"));
      }
    } catch (error) {
      log(error.toString());
      emit(MallsEditFailedState('An unexpected error occurred: $error'));
    }
  }
}
