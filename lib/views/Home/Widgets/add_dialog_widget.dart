import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_cubit.dart';
import 'package:sa7el/Cubit/service_provider/service_provider_states.dart';
import 'package:sa7el/Model/maintenance_model.dart' show Providers;
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/views/Home/Widgets/location_picker_widget.dart';

// Helper function to show messages using custom overlay toast
void _showMessage(BuildContext context, String message,
    {bool isError = false}) {
  _showCustomToast(context, message, isError: isError);
}

// Custom toast implementation using overlay
void _showCustomToast(BuildContext context, String message,
    {bool isError = false}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 80.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: isError ? 14.0 : 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Remove the overlay after a delay
  Future.delayed(Duration(seconds: isError ? 4 : 2), () {
    overlayEntry.remove();
  });
}

// Helper function for image picking
Future<String?> _pickImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );
    return image?.path;
  } catch (e) {
    log('Error picking image: $e');
    return null;
  }
}

// Helper function to convert image file to base64 string
Future<String?> _convertImageToBase64(String imagePath) async {
  try {
    log('DEBUG: Starting base64 conversion for: $imagePath');
    File imageFile = File(imagePath);
    log('DEBUG: File object created');

    bool exists = await imageFile.exists();
    log('DEBUG: File exists: $exists');

    if (exists) {
      log('DEBUG: Reading file bytes...');
      Uint8List imageBytes = await imageFile.readAsBytes();
      log('DEBUG: File bytes read, length: ${imageBytes.length}');

      String base64String = base64Encode(imageBytes);
      log('DEBUG: Base64 encoded, length: ${base64String.length}');
      final formattedBase64 = _ensureDataUrlPrefix(base64String);
      log('DEBUG: Full base64 string with prefix: $formattedBase64');

      return formattedBase64;
    } else {
      log('ERROR: Image file does not exist: $imagePath');
      return null;
    }
  } catch (e) {
    log('ERROR: Converting image to base64: $e');
    log('ERROR: Stack trace: ${StackTrace.current}');
    return null;
  }
}

// Helper function to ensure base64 string has data URL prefix
String _ensureDataUrlPrefix(String base64String) {
  if (base64String.startsWith('data:image/')) {
    // Already has a data URL prefix
    return base64String;
  } else {
    // Add the data URL prefix
    return 'data:image/png;base64,$base64String';
  }
}

// Add model classes for each entity type
class VillageAddModel {
  final String name;
  final String location;
  final String description;
  final String? arName;
  final String? arDescription;
  final int zoneId;
  final int status;
  final String? imageBase64;

  VillageAddModel({
    required this.name,
    required this.location,
    required this.description,
    this.arName,
    this.arDescription,
    required this.zoneId,
    required this.status,
    this.imageBase64,
  });

  static Future<VillageAddModel> fromFormData({
    required String name,
    required String location,
    required String description,
    String? arName,
    String? arDescription,
    required int zoneId,
    required int status,
    String? imagePath,
  }) async {
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      imageBase64 = await _convertImageToBase64(imagePath);
    }

    return VillageAddModel(
      name: name.trim(),
      location: location.trim(),
      description: description.trim(),
      arName: arName?.trim().isNotEmpty == true ? arName!.trim() : null,
      arDescription: arDescription?.trim().isNotEmpty == true
          ? arDescription!.trim()
          : null,
      zoneId: zoneId,
      status: status,
      imageBase64: imageBase64,
    );
  }

  Map<String, dynamic> toApiData() {
    log('=== VILLAGE ADD API DATA ===');
    log('DEBUG: VillageAddModel.toApiData() started');

    Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'description': description,
      'zone_id': zoneId,
      'status': status,
    };

    log('DEBUG: name field = $name');
    log('DEBUG: location field = $location');
    log('DEBUG: description field = $description');
    log('DEBUG: zone_id field = $zoneId');
    log('DEBUG: status field = $status');

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
      log('DEBUG: ar_name field = $arName');
    } else {
      log('DEBUG: ar_name field = EXCLUDED (empty or null)');
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
      log('DEBUG: ar_description field = $arDescription');
    } else {
      log('DEBUG: ar_description field = EXCLUDED (empty or null)');
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      log('DEBUG: image field = INCLUDED (${imageBase64!.length} characters)');
    } else {
      log('DEBUG: image field = EXCLUDED (no image)');
    }

    log('DEBUG: Village ADD - Final API data:');
    data.forEach((key, value) {
      if (key == 'image') {
        log('  $key: [BASE64_IMAGE_DATA] (${value.toString().length} chars) (${value.runtimeType})');
      } else {
        log('  $key: $value (${value.runtimeType})');
      }
    });
    log('=== END VILLAGE ADD API DATA ===');

    return data;
  }
}

class MallAddModel {
  final String name;
  final String description;
  final String openFrom;
  final String openTo;
  final int zoneId;
  final int status;
  final String? arName;
  final String? arDescription;
  final String? imageBase64;

  MallAddModel({
    required this.name,
    required this.description,
    required this.openFrom,
    required this.openTo,
    required this.zoneId,
    required this.status,
    this.arName,
    this.arDescription,
    this.imageBase64,
  });

  static Future<MallAddModel> fromFormData({
    required String name,
    required String description,
    required String openFrom,
    required String openTo,
    required int zoneId,
    required int status,
    String? arName,
    String? arDescription,
    String? imagePath,
  }) async {
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      imageBase64 = await _convertImageToBase64(imagePath);
    }

    return MallAddModel(
      name: name.trim(),
      description: description.trim(),
      openFrom: openFrom.trim(),
      openTo: openTo.trim(),
      zoneId: zoneId,
      status: status,
      arName: arName?.trim().isNotEmpty == true ? arName!.trim() : null,
      arDescription: arDescription?.trim().isNotEmpty == true
          ? arDescription!.trim()
          : null,
      imageBase64: imageBase64,
    );
  }

  Map<String, dynamic> toApiData() {
    log('=== MALL ADD API DATA ===');
    log('DEBUG: MallAddModel.toApiData() started');

    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'zone_id': zoneId,
      'status': status,
    };

    log('DEBUG: name field = $name');
    log('DEBUG: description field = $description');
    log('DEBUG: zone_id field = $zoneId');
    log('DEBUG: status field = $status');

    // Only include open_from if it has a value
    if (openFrom.isNotEmpty) {
      data['open_from'] = openFrom;
      log('DEBUG: open_from field = $openFrom');
    } else {
      log('DEBUG: open_from field = EXCLUDED (empty)');
    }

    // Only include open_to if it has a value
    if (openTo.isNotEmpty) {
      data['open_to'] = openTo;
      log('DEBUG: open_to field = $openTo');
    } else {
      log('DEBUG: open_to field = EXCLUDED (empty)');
    }

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
      log('DEBUG: ar_name field = $arName');
    } else {
      log('DEBUG: ar_name field = EXCLUDED (empty or null)');
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
      log('DEBUG: ar_description field = $arDescription');
    } else {
      log('DEBUG: ar_description field = EXCLUDED (empty or null)');
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      log('DEBUG: image field = INCLUDED (${imageBase64!.length} characters)');
    } else {
      log('DEBUG: image field = EXCLUDED (no image)');
    }

    log('DEBUG: Mall ADD - Final API data:');
    data.forEach((key, value) {
      if (key == 'image') {
        log('  $key: [BASE64_IMAGE_DATA] (${value.toString().length} chars) (${value.runtimeType})');
      } else {
        log('  $key: $value (${value.runtimeType})');
      }
    });
    log('=== END MALL ADD API DATA ===');

    return data;
  }
}

class ServiceProviderAddModel {
  final int serviceId;
  final String name;
  final String description;
  final String phone;
  final int status;
  final String? location;
  final String? arName;
  final String? arDescription;
  final String? imageBase64;
  final String? openFrom;
  final String? openTo;
  final int? zoneId;
  final int? villageId;
  final String? locationMap;

  ServiceProviderAddModel({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.phone,
    required this.status,
    this.location,
    this.arName,
    this.arDescription,
    this.imageBase64,
    this.openFrom,
    this.openTo,
    this.zoneId,
    this.villageId,
    this.locationMap,
  });

  static Future<ServiceProviderAddModel> fromFormData({
    required int serviceId,
    required String name,
    required String description,
    required String phone,
    required int status,
    String? location,
    String? arName,
    String? arDescription,
    String? imagePath,
    String? openFrom,
    String? openTo,
    int? zoneId,
    int? villageId,
    String? locationMap,
  }) async {
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      imageBase64 = await _convertImageToBase64(imagePath);
    }

    return ServiceProviderAddModel(
      serviceId: serviceId,
      name: name.trim(),
      description: description.trim(),
      phone: phone.trim(),
      status: status,
      location: location?.trim(),
      arName: arName?.trim().isNotEmpty == true ? arName!.trim() : null,
      arDescription: arDescription?.trim().isNotEmpty == true
          ? arDescription!.trim()
          : null,
      imageBase64: imageBase64,
      openFrom: openFrom?.trim(),
      openTo: openTo?.trim(),
      zoneId: zoneId,
      villageId: villageId,
      locationMap: locationMap?.trim(),
    );
  }

  Map<String, dynamic> toApiData() {
    log('=== SERVICE PROVIDER ADD API DATA ===');
    log('DEBUG: ServiceProviderAddModel.toApiData() - serviceId: $serviceId');

    Map<String, dynamic> data = {
      'service_id': serviceId,
      'name': name,
      'description': description,
      'phone': phone,
      'status': status,
    };

    log('DEBUG: service_id field = ${data['service_id']}');
    log('DEBUG: name field = ${data['name']}');
    log('DEBUG: description field = ${data['description']}');
    log('DEBUG: phone field = ${data['phone']}');
    log('DEBUG: status field = ${data['status']}');

    // Always include location
    data['location'] = location?.isNotEmpty == true ? location! : '';
    log('DEBUG: location field = ${data['location']}');

    // Always include ar_name
    data['ar_name'] = arName?.isNotEmpty == true ? arName! : '';
    log('DEBUG: ar_name field = ${data['ar_name']}');

    // Always include ar_description
    data['ar_description'] =
        arDescription?.isNotEmpty == true ? arDescription! : '';
    log('DEBUG: ar_description field = ${data['ar_description']}');

    // Only include open_from if it has a value
    if (openFrom?.isNotEmpty == true) {
      data['open_from'] = openFrom!;
      log('DEBUG: open_from field = ${data['open_from']}');
    } else {
      log('DEBUG: open_from field = EXCLUDED (empty or null)');
    }

    // Only include open_to if it has a value
    if (openTo?.isNotEmpty == true) {
      data['open_to'] = openTo!;
      log('DEBUG: open_to field = ${data['open_to']}');
    } else {
      log('DEBUG: open_to field = EXCLUDED (empty or null)');
    }

    // Include village_id only if it has a valid value
    if (villageId != null && villageId! > 0) {
      data['village_id'] = villageId;
      log('DEBUG: village_id field = ${data['village_id']}');
    } else {
      log('DEBUG: village_id field = EXCLUDED (null or 0)');
    }

    // Include zone_id only if it has a valid value
    if (zoneId != null && zoneId! > 0) {
      data['zone_id'] = zoneId;
      log('DEBUG: zone_id field = ${data['zone_id']}');
    } else {
      log('DEBUG: zone_id field = EXCLUDED (null or 0)');
    }

    // Always provide location_map
    data['location_map'] = locationMap?.isNotEmpty == true
        ? locationMap!
        : 'https://maps.google.com/maps?q=24.7136,46.6753'; // Default to Riyadh
    log('DEBUG: location_map field = ${data['location_map']}');

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      log('DEBUG: image field = INCLUDED (${imageBase64!.length} characters)');
    } else {
      log('DEBUG: image field = EXCLUDED (no image)');
    }

    log('DEBUG: ServiceProvider ADD - Final API data:');
    data.forEach((key, value) {
      if (key == 'image') {
        log('  $key: [BASE64_IMAGE_DATA] (${value.toString().length} chars) (${value.runtimeType})');
      } else {
        log('  $key: $value (${value.runtimeType})');
      }
    });
    log('=== END SERVICE PROVIDER ADD API DATA ===');

    return data;
  }
}

class MaintenanceProviderAddModel {
  final String name;
  final String description;
  final String phone;
  final String location;
  final String openFrom;
  final String openTo;
  final int maintenanceTypeId;
  final int status;
  final String? arName;
  final String? arDescription;
  final String? imageBase64;
  final int? villageId;
  final String? locationMap;

  MaintenanceProviderAddModel({
    required this.name,
    required this.description,
    required this.phone,
    required this.location,
    required this.openFrom,
    required this.openTo,
    required this.maintenanceTypeId,
    required this.status,
    this.arName,
    this.arDescription,
    this.imageBase64,
    this.villageId,
    this.locationMap,
  });

  static Future<MaintenanceProviderAddModel> fromFormData({
    required String name,
    required String description,
    required String phone,
    required String location,
    required String openFrom,
    required String openTo,
    required int maintenanceTypeId,
    required int status,
    String? arName,
    String? arDescription,
    String? imagePath,
    int? villageId,
    String? locationMap,
  }) async {
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      imageBase64 = await _convertImageToBase64(imagePath);
    }

    return MaintenanceProviderAddModel(
      name: name.trim(),
      description: description.trim(),
      phone: phone.trim(),
      location: location.trim(),
      openFrom: openFrom.trim(),
      openTo: openTo.trim(),
      maintenanceTypeId: maintenanceTypeId,
      status: status,
      arName: arName?.trim().isNotEmpty == true ? arName!.trim() : null,
      arDescription: arDescription?.trim().isNotEmpty == true
          ? arDescription!.trim()
          : null,
      imageBase64: imageBase64,
      villageId: villageId,
      locationMap: locationMap?.trim(),
    );
  }

  Map<String, dynamic> toApiData() {
    log('=== MAINTENANCE PROVIDER ADD API DATA ===');
    log('DEBUG: MaintenanceProviderAddModel.toApiData() started');
    log('DEBUG: maintenanceTypeId (in body): $maintenanceTypeId');
    log('DEBUG: villageId (in body): $villageId');

    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'phone': phone,
      'location': location,
      'maintenance_type_id': maintenanceTypeId,
      'status': status,
    };

    log('DEBUG: name field = $name');
    log('DEBUG: description field = $description');
    log('DEBUG: phone field = $phone');
    log('DEBUG: location field = $location');
    log('DEBUG: maintenance_type_id field = $maintenanceTypeId');
    log('DEBUG: status field = $status');

    // Only include open_from if it has a value
    if (openFrom.isNotEmpty) {
      data['open_from'] = openFrom;
      log('DEBUG: open_from field = $openFrom');
    } else {
      log('DEBUG: open_from field = EXCLUDED (empty)');
    }

    // Only include open_to if it has a value
    if (openTo.isNotEmpty) {
      data['open_to'] = openTo;
      log('DEBUG: open_to field = $openTo');
    } else {
      log('DEBUG: open_to field = EXCLUDED (empty)');
    }

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
      log('DEBUG: ar_name field = $arName');
    } else {
      log('DEBUG: ar_name field = EXCLUDED (empty or null)');
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
      log('DEBUG: ar_description field = $arDescription');
    } else {
      log('DEBUG: ar_description field = EXCLUDED (empty or null)');
    }

    if (villageId != null && villageId! > 0) {
      data['village_id'] = villageId;
      log('DEBUG: village_id field = $villageId');
    } else {
      log('DEBUG: village_id field = EXCLUDED (null or 0)');
    }

    // Add location map handling
    data['location_map'] = locationMap?.isNotEmpty == true
        ? locationMap!
        : 'https://maps.google.com/maps?q=24.7136,46.6753'; // Default to Riyadh
    log('DEBUG: location_map field = ${data['location_map']}');

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      log('DEBUG: image field = INCLUDED (${imageBase64!.length} characters)');
    } else {
      log('DEBUG: image field = EXCLUDED (no image)');
    }

    log('DEBUG: MaintenanceProvider ADD - Final API data:');
    data.forEach((key, value) {
      if (key == 'image') {
        log('  $key: [BASE64_IMAGE_DATA] (${value.toString().length} chars) (${value.runtimeType})');
      } else {
        log('  $key: $value (${value.runtimeType})');
      }
    });
    log('=== END MAINTENANCE PROVIDER ADD API DATA ===');

    return data;
  }
}

void showAddDialog(BuildContext context, dynamic item, dynamic cubit) {
  log('DEBUG: showAddDialog called for item type: ${item.runtimeType}');
  log('DEBUG: cubit type: ${cubit.runtimeType}');

  // Get screen dimensions for responsive design
  final screenSize = MediaQuery.of(context).size;
  final isTablet = screenSize.width > 600;
  final isDesktop = screenSize.width > 1024;

  // Responsive dimensions
  final dialogWidth = isDesktop
      ? screenSize.width * 0.5
      : isTablet
          ? screenSize.width * 0.7
          : screenSize.width * 0.9;

  final dialogHeight = isDesktop
      ? screenSize.height * 0.7
      : isTablet
          ? screenSize.height * 0.8
          : screenSize.height * 0.85;

  // Responsive font sizes
  final titleFontSize = isDesktop
      ? 24.0
      : isTablet
          ? 20.0
          : 18.0;
  final labelFontSize = isDesktop
      ? 16.0
      : isTablet
          ? 14.0
          : 12.0;
  final buttonFontSize = isDesktop
      ? 16.0
      : isTablet
          ? 14.0
          : 12.0;

  // Responsive spacing
  final verticalSpacing = isDesktop
      ? 20.0
      : isTablet
          ? 16.0
          : 12.0;
  final horizontalPadding = isDesktop
      ? 24.0
      : isTablet
          ? 20.0
          : 16.0;

  // Determine entity type from item instance
  String entityType = '';
  if (item is Villages) {
    entityType = 'Village';
  } else if (item is ServiceProviderModel) {
    entityType = 'Service Provider';
  } else if (item is Providers) {
    entityType = 'Maintenance Provider';
  } else if (item is MallModel) {
    entityType = 'Mall';
  } else {
    log('ERROR: Unhandled item type for add dialog: ${item.runtimeType}');
    return; // Don't show dialog for unknown type
  }

  // Initialize controllers with empty values for new entity
  final TextEditingController nameController = TextEditingController();
  final TextEditingController arNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController arDescriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController locationMapController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController openFromController = TextEditingController();
  final TextEditingController openToController = TextEditingController();

  // Status and other selections
  num selectedStatus = 1; // Default to active
  int? selectedMaintenanceTypeId;
  int? selectedVillageId;
  int? selectedZoneId;
  int? selectedServiceId;
  String? imagePath;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: dialogWidth,
              height: dialogHeight,
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Add New $entityType',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: WegoColors.mainColor,
                            fontSize: titleFontSize,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: isDesktop ? 24 : 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: verticalSpacing),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Name (English) - All entities
                          _buildResponsiveTextField(
                            controller: nameController,
                            label: '$entityType Name (English)',
                            icon: Icons.person,
                            isRequired: true,
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(height: verticalSpacing),

                          // Name (Arabic) - All entities
                          _buildResponsiveTextField(
                            controller: arNameController,
                            label: '$entityType Name (Arabic)',
                            icon: Icons.person_outline,
                            textDirection: TextDirection.rtl,
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(height: verticalSpacing),

                          // Description (English) - All entities
                          _buildResponsiveTextField(
                            controller: descriptionController,
                            label: 'Description (English)',
                            icon: Icons.description,
                            maxLines: 3,
                            isRequired: false,
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(height: verticalSpacing),

                          // Description (Arabic) - All entities
                          _buildResponsiveTextField(
                            controller: arDescriptionController,
                            label: 'Description (Arabic)',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            textDirection: TextDirection.rtl,
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(height: verticalSpacing),

                          // Location - All entities except Mall
                          if (entityType != 'Mall') ...[
                            // Location Picker Button
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 16 : 12,
                                vertical: isDesktop ? 16 : 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: WegoColors.mainColor,
                                        size: isDesktop ? 24 : 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Location *',
                                        style: TextStyle(
                                          fontSize: labelFontSize,
                                          fontWeight: FontWeight.w500,
                                          color: WegoColors.mainColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    locationController.text.isNotEmpty
                                        ? locationController.text
                                        : 'Tap to select location on map',
                                    style: TextStyle(
                                      fontSize: labelFontSize - 1,
                                      color: locationController.text.isNotEmpty
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  if (locationMapController
                                      .text.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      'Location Map Link: ${locationMapController.text}',
                                      style: TextStyle(
                                        fontSize: labelFontSize - 2,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LocationPickerWidget(
                                                  initialLocation:
                                                      locationController
                                                              .text.isNotEmpty
                                                          ? locationController
                                                              .text
                                                          : null,
                                                  initialLocationMap:
                                                      locationMapController
                                                              .text.isNotEmpty
                                                          ? locationMapController
                                                              .text
                                                          : null,
                                                  onLocationSelected:
                                                      (address, coordinates) {
                                                    setState(() {
                                                      locationController.text =
                                                          address;
                                                      locationMapController
                                                          .text = coordinates;
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.map,
                                            size: isDesktop ? 20 : 18,
                                          ),
                                          label: Text(
                                            'Select on Map',
                                            style: TextStyle(
                                                fontSize: labelFontSize - 1),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                WegoColors.mainColor,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isDesktop ? 20 : 16,
                                              vertical: isDesktop ? 12 : 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (locationController
                                          .text.isNotEmpty) ...[
                                        SizedBox(width: 8),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              locationController.clear();
                                              locationMapController.clear();
                                            });
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.red,
                                            size: isDesktop ? 24 : 20,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Phone - Service Provider and Maintenance Provider only
                          if (entityType == 'Service Provider' ||
                              entityType == 'Maintenance Provider') ...[
                            _buildResponsiveTextField(
                              controller: phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone,
                              isRequired: true,
                              fontSize: labelFontSize,
                              isDesktop: isDesktop,
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Open From - Service Provider, Maintenance Provider and Mall
                          if (entityType != 'Village') ...[
                            _buildResponsiveTimeField(
                              controller: openFromController,
                              label: 'Open From',
                              icon: Icons.access_time,
                              fontSize: labelFontSize,
                              isDesktop: isDesktop,
                              context: context,
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Open To - Service Provider, Maintenance Provider and Mall
                          if (entityType != 'Village') ...[
                            _buildResponsiveTimeField(
                              controller: openToController,
                              label: 'Open To',
                              icon: Icons.access_time_filled,
                              fontSize: labelFontSize,
                              isDesktop: isDesktop,
                              context: context,
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Zone Dropdown - Village and Mall only
                          if (entityType == 'Village' ||
                              entityType == 'Mall') ...[
                            BlocBuilder<VillageCubit, VillageStates>(
                              builder: (context, state) {
                                final villageCubit = VillageCubit.get(context);
                                return _buildResponsiveDropdown<int>(
                                  value: selectedZoneId,
                                  label: 'Select Zone *',
                                  icon: Icons.map,
                                  items: villageCubit.zones.map((zone) {
                                    return DropdownMenuItem<int>(
                                      value: zone.id?.toInt(),
                                      child: Text(
                                        zone.name ?? 'Unnamed Zone',
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedZoneId = value;
                                    });
                                  },
                                  fontSize: labelFontSize,
                                  isDesktop: isDesktop,
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Village Dropdown - Service Provider only
                          if (entityType == 'Service Provider') ...[
                            BlocBuilder<VillageCubit, VillageStates>(
                              builder: (context, state) {
                                final villageCubit = VillageCubit.get(context);
                                return _buildResponsiveDropdown<int>(
                                  value: selectedVillageId,
                                  label: 'Select Village (Optional)',
                                  icon: Icons.location_city,
                                  items: [
                                    DropdownMenuItem<int>(
                                      value: null,
                                      child: Text(
                                        'No Village',
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    ),
                                    ...villageCubit.items.map((village) {
                                      return DropdownMenuItem<int>(
                                        value: village.id?.toInt(),
                                        child: Text(
                                          village.name ?? 'Unnamed Village',
                                          style: TextStyle(
                                              fontSize: labelFontSize),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVillageId = value;
                                    });
                                  },
                                  fontSize: labelFontSize,
                                  isDesktop: isDesktop,
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Zone Dropdown - Service Provider only
                          if (entityType == 'Service Provider') ...[
                            BlocBuilder<VillageCubit, VillageStates>(
                              builder: (context, state) {
                                final villageCubit = VillageCubit.get(context);
                                return _buildResponsiveDropdown<int>(
                                  value: selectedZoneId,
                                  label: 'Select Zone (Optional)',
                                  icon: Icons.map,
                                  items: [
                                    DropdownMenuItem<int>(
                                      value: null,
                                      child: Text(
                                        'No Zone',
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    ),
                                    ...villageCubit.zones.map((zone) {
                                      return DropdownMenuItem<int>(
                                        value: zone.id?.toInt(),
                                        child: Text(
                                          zone.name ?? 'Unnamed Zone',
                                          style: TextStyle(
                                              fontSize: labelFontSize),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedZoneId = value;
                                    });
                                  },
                                  fontSize: labelFontSize,
                                  isDesktop: isDesktop,
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Service Type Dropdown - Service Provider only
                          if (entityType == 'Service Provider') ...[
                            BlocBuilder<ServiceProviderCubit,
                                ServiceProviderStates>(
                              builder: (context, state) {
                                final serviceProviderCubit =
                                    BlocProvider.of<ServiceProviderCubit>(
                                        context);
                                // Extract unique service types from service providers
                                final uniqueServices = <int, ServiceType>{};
                                for (var provider
                                    in serviceProviderCubit.items) {
                                  if (provider.service != null) {
                                    uniqueServices[provider.service!.id] =
                                        provider.service!;
                                  }
                                }

                                return _buildResponsiveDropdown<int>(
                                  value: selectedServiceId,
                                  label: 'Select Service Type *',
                                  icon: Icons.business,
                                  items: uniqueServices.values.map((service) {
                                    return DropdownMenuItem<int>(
                                      value: service.id,
                                      child: Text(
                                        service.name,
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedServiceId = value;
                                    });
                                  },
                                  fontSize: labelFontSize,
                                  isDesktop: isDesktop,
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Village Dropdown - Maintenance Provider only
                          if (entityType == 'Maintenance Provider') ...[
                            BlocBuilder<VillageCubit, VillageStates>(
                              builder: (context, state) {
                                final villageCubit = VillageCubit.get(context);
                                return _buildResponsiveDropdown<int>(
                                  value: selectedVillageId,
                                  label: 'Select Village (Optional)',
                                  icon: Icons.location_city,
                                  items: [
                                    DropdownMenuItem<int>(
                                      value: null,
                                      child: Text(
                                        'No Village',
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    ),
                                    ...villageCubit.items.map((village) {
                                      return DropdownMenuItem<int>(
                                        value: village.id?.toInt(),
                                        child: Text(
                                          village.name ?? 'Unnamed Village',
                                          style: TextStyle(
                                              fontSize: labelFontSize),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVillageId = value;
                                    });
                                  },
                                  fontSize: labelFontSize,
                                  isDesktop: isDesktop,
                                );
                              },
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Maintenance Type Dropdown - Maintenance Provider only
                          if (entityType == 'Maintenance Provider') ...[
                            _buildResponsiveDropdown<int>(
                              value: selectedMaintenanceTypeId,
                              label: 'Maintenance Type *',
                              icon: Icons.build,
                              items: cubit.maintenanceTypes
                                      ?.map<DropdownMenuItem<int>>(
                                          (maintenanceType) {
                                    return DropdownMenuItem<int>(
                                      value: maintenanceType.id?.toInt(),
                                      child: Text(
                                        maintenanceType.name ?? 'Unknown',
                                        style:
                                            TextStyle(fontSize: labelFontSize),
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                              onChanged: (int? value) {
                                setState(() {
                                  selectedMaintenanceTypeId = value;
                                });
                              },
                              fontSize: labelFontSize,
                              isDesktop: isDesktop,
                            ),
                            SizedBox(height: verticalSpacing),
                          ],

                          // Status Switch - All entities
                          _buildResponsiveStatusSwitch(
                            selectedStatus: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ? 1 : 0;
                              });
                            },
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(height: verticalSpacing),

                          // Image Upload Section - All entities
                          _buildResponsiveImageUpload(
                            imagePath: imagePath,
                            onImageSelected: (path) {
                              setState(() {
                                imagePath = path;
                              });
                            },
                            onImageRemoved: () {
                              setState(() {
                                imagePath = null;
                              });
                            },
                            fontSize: labelFontSize,
                            isDesktop: isDesktop,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate required fields based on entity type
                          bool isValid = true;
                          String errorMessage = '';

                          if (nameController.text.trim().isEmpty) {
                            isValid = false;
                            errorMessage = 'Please fill in all required fields';
                          }

                          // Image validation - required for all entities
                          if (imagePath == null) {
                            isValid = false;
                            errorMessage = 'Image is required';
                          }

                          // Entity-specific validation
                          if (entityType == 'Village' &&
                              (locationController.text.trim().isEmpty ||
                                  selectedZoneId == null)) {
                            isValid = false;
                            errorMessage =
                                'Location and Zone are required for villages';
                          }

                          if (entityType == 'Mall' &&
                              (selectedZoneId == null)) {
                            isValid = false;
                            errorMessage = 'Zone is required for malls';
                          }

                          if (entityType == 'Service Provider' &&
                              (phoneController.text.trim().isEmpty ||
                                  locationController.text.trim().isEmpty ||
                                  selectedServiceId == null)) {
                            isValid = false;
                            errorMessage =
                                'Phone, Location, and Service Type are required for service provider';
                          }

                          if (entityType == 'Maintenance Provider' &&
                              (phoneController.text.trim().isEmpty ||
                                  locationController.text.trim().isEmpty ||
                                  selectedMaintenanceTypeId == null)) {
                            isValid = false;
                            errorMessage =
                                'Phone, Location, and Maintenance Type are required for maintenance provider';
                          }

                          if (!isValid) {
                            _showMessage(context, errorMessage, isError: true);
                            return;
                          }

                          try {
                            if (cubit != null) {
                              // Create appropriate add model based on entity type
                              bool addSuccess = false;

                              if (entityType == 'Village') {
                                VillageAddModel addModel =
                                    await VillageAddModel.fromFormData(
                                  name: nameController.text.trim(),
                                  location: locationController.text.trim(),
                                  description:
                                      descriptionController.text.trim(),
                                  arName: arNameController.text.trim(),
                                  arDescription:
                                      arDescriptionController.text.trim(),
                                  zoneId: selectedZoneId ?? 0,
                                  status: selectedStatus.toInt(),
                                  imagePath: imagePath,
                                );
                                await cubit.addData(addModel);
                                addSuccess = true;
                              } else if (entityType == 'Mall') {
                                MallAddModel addModel =
                                    await MallAddModel.fromFormData(
                                  name: nameController.text.trim(),
                                  description:
                                      descriptionController.text.trim(),
                                  openFrom: openFromController.text.trim(),
                                  openTo: openToController.text.trim(),
                                  zoneId: selectedZoneId ?? 0,
                                  status: selectedStatus.toInt(),
                                  arName: arNameController.text.trim(),
                                  arDescription:
                                      arDescriptionController.text.trim(),
                                  imagePath: imagePath,
                                );
                                await cubit.addData(addModel);
                                addSuccess = true;
                              } else if (entityType == 'Service Provider') {
                                log('DEBUG: Service Provider Add - selectedServiceId: $selectedServiceId');
                                ServiceProviderAddModel addModel =
                                    await ServiceProviderAddModel.fromFormData(
                                  serviceId: selectedServiceId ?? 0,
                                  name: nameController.text.trim(),
                                  description:
                                      descriptionController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  status: selectedStatus.toInt(),
                                  location: locationController.text.trim(),
                                  arName: arNameController.text.trim(),
                                  arDescription:
                                      arDescriptionController.text.trim(),
                                  imagePath: imagePath,
                                  openFrom: openFromController.text.trim(),
                                  openTo: openToController.text.trim(),
                                  zoneId: selectedZoneId,
                                  villageId: selectedVillageId,
                                  locationMap:
                                      locationMapController.text.trim(),
                                );
                                log('DEBUG: Service Provider Add - serviceId in model: ${addModel.serviceId}');
                                await cubit.addData(addModel);
                                addSuccess = true;
                              } else if (entityType == 'Maintenance Provider') {
                                MaintenanceProviderAddModel addModel =
                                    await MaintenanceProviderAddModel
                                        .fromFormData(
                                  name: nameController.text.trim(),
                                  description:
                                      descriptionController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  location: locationController.text.trim(),
                                  openFrom: openFromController.text.trim(),
                                  openTo: openToController.text.trim(),
                                  maintenanceTypeId:
                                      selectedMaintenanceTypeId ?? 0,
                                  status: selectedStatus.toInt(),
                                  arName: arNameController.text.trim(),
                                  arDescription:
                                      arDescriptionController.text.trim(),
                                  imagePath: imagePath,
                                  villageId: selectedVillageId,
                                  locationMap:
                                      locationMapController.text.trim(),
                                );
                                await cubit.addData(addModel);
                                addSuccess = true;
                              }

                              // If add was successful, refresh the data
                              if (addSuccess) {
                                // Trigger refresh by calling getData
                                if (entityType == 'Village') {
                                  cubit.getData();
                                } else if (entityType == 'Mall') {
                                  cubit.getData();
                                } else if (entityType == 'Service Provider') {
                                  cubit.getData();
                                } else if (entityType ==
                                    'Maintenance Provider') {
                                  cubit.getData();
                                }

                                // Show success message
                                _showMessage(
                                    context, '$entityType added successfully!');
                              }
                            }
                          } catch (e) {
                            String errorMessage =
                                'Error adding $entityType: $e';

                            // If it's a DioException, try to get more detailed error info
                            if (e is DioException) {
                              String responseData = '';
                              if (e.response?.data != null) {
                                try {
                                  responseData =
                                      '\nResponse: ${e.response!.data.toString()}';
                                } catch (parseError) {
                                  responseData =
                                      '\nResponse: Unable to parse response data';
                                }
                              }
                              errorMessage =
                                  'Error adding $entityType: ${e.message ?? e.toString()}$responseData';
                            }

                            _showMessage(context, errorMessage, isError: true);
                          }

                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WegoColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24 : 16,
                            vertical: isDesktop ? 16 : 12,
                          ),
                        ),
                        child: Text(
                          'Add $entityType',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildResponsiveTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isRequired = false,
  int maxLines = 1,
  TextDirection? textDirection,
  required double fontSize,
  required bool isDesktop,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: textDirection,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize * 0.9),
        prefixIcon: Icon(
          icon,
          color: WegoColors.mainColor,
          size: isDesktop ? 24 : 20,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 16 : 12,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    ),
  );
}

Widget _buildResponsiveDropdown<T>({
  required T? value,
  required String label,
  required IconData icon,
  required List<DropdownMenuItem<T>> items,
  required void Function(T?) onChanged,
  required double fontSize,
  required bool isDesktop,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize * 0.9),
        prefixIcon: Icon(
          icon,
          color: WegoColors.mainColor,
          size: isDesktop ? 24 : 20,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 16 : 12,
        ),
      ),
      items: items,
      onChanged: onChanged,
      style: TextStyle(fontSize: fontSize, color: Colors.black),
    ),
  );
}

Widget _buildResponsiveStatusSwitch({
  required num selectedStatus,
  required void Function(bool) onChanged,
  required double fontSize,
  required bool isDesktop,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isDesktop ? 16 : 12,
      vertical: isDesktop ? 12 : 8,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.toggle_on,
              color: WegoColors.mainColor,
              size: isDesktop ? 24 : 20,
            ),
            SizedBox(width: 8),
            Text(
              'Status *',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Switch(
          value: selectedStatus == 1,
          onChanged: onChanged,
          activeColor: WegoColors.mainColor,
        ),
      ],
    ),
  );
}

Widget _buildResponsiveImageUpload({
  required String? imagePath,
  required void Function(String?) onImageSelected,
  required void Function() onImageRemoved,
  required double fontSize,
  required bool isDesktop,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.image,
            color: WegoColors.mainColor,
            size: isDesktop ? 24 : 20,
          ),
          title: Text(
            imagePath != null ? 'Image Selected' : 'Select Image *',
            style: TextStyle(fontSize: fontSize),
          ),
          subtitle: imagePath != null
              ? Text(
                  imagePath.split('/').last,
                  style: TextStyle(fontSize: fontSize * 0.8),
                )
              : Text(
                  'Tap to choose an image (Required)',
                  style: TextStyle(fontSize: fontSize * 0.8),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.red,
                    size: isDesktop ? 20 : 18,
                  ),
                  onPressed: onImageRemoved,
                ),
              Icon(
                Icons.upload_file,
                size: isDesktop ? 20 : 18,
              ),
            ],
          ),
          onTap: () async {
            final path = await _pickImage();
            if (path != null) {
              onImageSelected(path);
            }
          },
        ),
        if (imagePath != null) ...[
          const Divider(height: 1),
          Container(
            height: isDesktop ? 120 : 100,
            width: double.infinity,
            margin: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildResponsiveTimeField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required double fontSize,
  required bool isDesktop,
  required BuildContext context,
}) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: fontSize * 0.9),
        prefixIcon: Icon(
          icon,
          color: WegoColors.mainColor,
          size: isDesktop ? 24 : 20,
        ),
        suffixIcon: Icon(
          Icons.schedule,
          color: WegoColors.mainColor,
          size: isDesktop ? 20 : 18,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : 12,
          vertical: isDesktop ? 16 : 12,
        ),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          // Format time as hh:mm:ss
          String formattedTime =
              '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}:00';
          controller.text = formattedTime;
        }
      },
    ),
  );
}
