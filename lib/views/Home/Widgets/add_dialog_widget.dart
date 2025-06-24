import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/Model/maintenance_provider_model.dart';
import 'package:sa7el/Model/maintenance_model.dart' show Providers;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    print('Error picking image: $e');
    return null;
  }
}

// Helper function to convert image file to base64 string
Future<String?> _convertImageToBase64(String imagePath) async {
  try {
    print('DEBUG: Starting base64 conversion for: $imagePath');
    File imageFile = File(imagePath);
    print('DEBUG: File object created');

    bool exists = await imageFile.exists();
    print('DEBUG: File exists: $exists');

    if (exists) {
      print('DEBUG: Reading file bytes...');
      Uint8List imageBytes = await imageFile.readAsBytes();
      print('DEBUG: File bytes read, length: ${imageBytes.length}');

      String base64String = base64Encode(imageBytes);
      print('DEBUG: Base64 encoded, length: ${base64String.length}');
      final formattedBase64 = _ensureDataUrlPrefix(base64String);
      print('DEBUG: Full base64 string with prefix: $formattedBase64');

      return formattedBase64;
    } else {
      print('ERROR: Image file does not exist: $imagePath');
      return null;
    }
  } catch (e) {
    print('ERROR: Converting image to base64: $e');
    print('ERROR: Stack trace: ${StackTrace.current}');
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
    Map<String, dynamic> data = {
      'name': name,
      'location': location,
      'description': description,
      'zone_id': zoneId,
      'status': status,
    };

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
    }

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
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'open_from': openFrom,
      'open_to': openTo,
      'zone_id': zoneId,
      'status': status,
    };

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
    }

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
    Map<String, dynamic> data = {
      'service_id': serviceId,
      'name': name,
      'description': description,
      'phone': phone,
      'status': status,
    };

    // Always include location
    data['location'] = location?.isNotEmpty == true ? location! : '';

    // Always include ar_name
    data['ar_name'] = arName?.isNotEmpty == true ? arName! : '';

    // Always include ar_description
    data['ar_description'] =
        arDescription?.isNotEmpty == true ? arDescription! : '';

    // Always include open_from
    data['open_from'] = openFrom?.isNotEmpty == true ? openFrom! : '';

    // Always include open_to
    data['open_to'] = openTo?.isNotEmpty == true ? openTo! : '';

    // Include village_id only if it has a valid value
    if (villageId != null && villageId! > 0) {
      data['village_id'] = villageId;
    }

    // Include zone_id only if it has a valid value
    if (zoneId != null && zoneId! > 0) {
      data['zone_id'] = zoneId;
    }

    // Always provide location_map
    data['location_map'] = locationMap?.isNotEmpty == true
        ? locationMap!
        : 'https://maps.google.com';

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
    }

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
    );
  }

  Map<String, dynamic> toApiData() {
    Map<String, dynamic> data = {
      'name': name,
      'description': description,
      'phone': phone,
      'location': location,
      'open_from': openFrom,
      'open_to': openTo,
      'maintenance_type_id': maintenanceTypeId,
      'status': status,
    };

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
    }

    if (villageId != null && villageId! > 0) {
      data['village_id'] = villageId;
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
    }

    return data;
  }
}

void showAddDialog(BuildContext context, dynamic item, dynamic cubit) {
  print('DEBUG: showAddDialog called for item type: ${item.runtimeType}');
  print('DEBUG: cubit type: ${cubit.runtimeType}');

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
    print('ERROR: Unhandled item type for add dialog: ${item.runtimeType}');
    return; // Don't show dialog for unknown type
  }

  // Initialize controllers with empty values for new entity
  final TextEditingController nameController = TextEditingController();
  final TextEditingController arNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController arDescriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController openFromController = TextEditingController();
  final TextEditingController openToController = TextEditingController();
  final TextEditingController zoneIdController = TextEditingController();
  final TextEditingController villageIdController = TextEditingController();
  final TextEditingController serviceIdController = TextEditingController();

  // Status and other selections
  num selectedStatus = 1; // Default to active
  int? selectedMaintenanceTypeId;
  String? imagePath;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Add New $entityType',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: WegoColors.mainColor,
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name (English) - All entities
                    _buildTextField(
                      controller: nameController,
                      label: '$entityType Name (English)',
                      icon: Icons.person,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // Name (Arabic) - All entities
                    _buildTextField(
                      controller: arNameController,
                      label: '$entityType Name (Arabic)',
                      icon: Icons.person_outline,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),

                    // Description (English) - All entities
                    _buildTextField(
                      controller: descriptionController,
                      label: 'Description (English)',
                      icon: Icons.description,
                      maxLines: 3,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // Description (Arabic) - All entities
                    _buildTextField(
                      controller: arDescriptionController,
                      label: 'Description (Arabic)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),

                    // Location - All entities except Mall
                    if (entityType != 'Mall') ...[
                      _buildTextField(
                        controller: locationController,
                        label: 'Location',
                        icon: Icons.location_on,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Phone - Service Provider and Maintenance Provider only
                    if (entityType == 'Service Provider' ||
                        entityType == 'Maintenance Provider') ...[
                      _buildTextField(
                        controller: phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Open From - Service Provider, Maintenance Provider and Mall
                    if (entityType != 'Village') ...[
                      _buildTextField(
                        controller: openFromController,
                        label: 'Open From',
                        icon: Icons.access_time,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Open To - Service Provider, Maintenance Provider and Mall
                    if (entityType != 'Village') ...[
                      _buildTextField(
                        controller: openToController,
                        label: 'Open To',
                        icon: Icons.access_time_filled,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Zone ID - Village and Mall only
                    if (entityType == 'Village' || entityType == 'Mall') ...[
                      _buildTextField(
                        controller: zoneIdController,
                        label: 'Zone ID',
                        icon: Icons.map,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Village ID - Service Provider only
                    if (entityType == 'Service Provider') ...[
                      _buildTextField(
                        controller: villageIdController,
                        label: 'Village ID',
                        icon: Icons.location_city,
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Zone ID - Service Provider only
                    if (entityType == 'Service Provider') ...[
                      _buildTextField(
                        controller: zoneIdController,
                        label: 'Zone ID',
                        icon: Icons.map,
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Service ID - Service Provider only
                    if (entityType == 'Service Provider') ...[
                      _buildTextField(
                        controller: serviceIdController,
                        label: 'Service ID',
                        icon: Icons.business,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Village ID - Maintenance Provider only
                    if (entityType == 'Maintenance Provider') ...[
                      _buildTextField(
                        controller: villageIdController,
                        label: 'Village ID',
                        icon: Icons.location_city,
                        isRequired: false,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Maintenance Type Dropdown - Maintenance Provider only
                    if (entityType == 'Maintenance Provider') ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int>(
                          value: selectedMaintenanceTypeId,
                          decoration: InputDecoration(
                            labelText: 'Maintenance Type *',
                            prefixIcon:
                                Icon(Icons.build, color: WegoColors.mainColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          items: cubit.maintenanceTypes
                                  ?.map<DropdownMenuItem<int>>(
                                      (maintenanceType) {
                                return DropdownMenuItem<int>(
                                  value: maintenanceType.id?.toInt(),
                                  child:
                                      Text(maintenanceType.name ?? 'Unknown'),
                                );
                              }).toList() ??
                              [],
                          onChanged: (int? value) {
                            setState(() {
                              selectedMaintenanceTypeId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a maintenance type';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Status Switch - All entities
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.toggle_on, color: WegoColors.mainColor),
                            SizedBox(width: 8),
                            Text(
                              'Status *',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: selectedStatus == 1,
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value ? 1 : 0;
                            });
                          },
                          activeColor: WegoColors.mainColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Image Upload Section - All entities
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.image,
                                color: WegoColors.mainColor),
                            title: Text(imagePath != null
                                ? 'Image Selected'
                                : 'Select Image (Optional)'),
                            subtitle: imagePath != null
                                ? Text(imagePath!.split('/').last)
                                : const Text('Tap to choose an image'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (imagePath != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        imagePath = null;
                                      });
                                    },
                                  ),
                                const Icon(Icons.upload_file),
                              ],
                            ),
                            onTap: () async {
                              final path = await _pickImage();
                              if (path != null) {
                                setState(() {
                                  imagePath = path;
                                });
                              }
                            },
                          ),
                          if (imagePath != null) ...[
                            const Divider(height: 1),
                            Container(
                              height: 100,
                              width: double.infinity,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate required fields based on entity type
                  bool isValid = true;
                  String errorMessage = '';

                  if (nameController.text.trim().isEmpty ||
                      descriptionController.text.trim().isEmpty) {
                    isValid = false;
                    errorMessage = 'Please fill in all required fields';
                  }

                  // Entity-specific validation
                  if (entityType == 'Village' &&
                      (locationController.text.trim().isEmpty ||
                          zoneIdController.text.trim().isEmpty)) {
                    isValid = false;
                    errorMessage =
                        'Location and Zone ID are required for villages';
                  }

                  if (entityType == 'Mall' &&
                      (openFromController.text.trim().isEmpty ||
                          openToController.text.trim().isEmpty ||
                          zoneIdController.text.trim().isEmpty)) {
                    isValid = false;
                    errorMessage =
                        'Open From, Open To, and Zone ID are required for malls';
                  }

                  if (entityType == 'Service Provider' &&
                      (phoneController.text.trim().isEmpty ||
                          openFromController.text.trim().isEmpty ||
                          openToController.text.trim().isEmpty ||
                          locationController.text.trim().isEmpty ||
                          serviceIdController.text.trim().isEmpty)) {
                    isValid = false;
                    errorMessage =
                        'All required fields must be filled for service provider';
                  }

                  if (entityType == 'Maintenance Provider' &&
                      (phoneController.text.trim().isEmpty ||
                          openFromController.text.trim().isEmpty ||
                          openToController.text.trim().isEmpty ||
                          locationController.text.trim().isEmpty ||
                          selectedMaintenanceTypeId == null)) {
                    isValid = false;
                    errorMessage =
                        'All required fields must be filled for maintenance provider';
                  }

                  if (!isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    if (cubit != null) {
                      // Create appropriate add model based on entity type
                      if (entityType == 'Village') {
                        VillageAddModel addModel =
                            await VillageAddModel.fromFormData(
                          name: nameController.text.trim(),
                          location: locationController.text.trim(),
                          description: descriptionController.text.trim(),
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          zoneId:
                              int.tryParse(zoneIdController.text.trim()) ?? 0,
                          status: selectedStatus.toInt(),
                          imagePath: imagePath,
                        );
                        cubit.addData(addModel);
                      } else if (entityType == 'Mall') {
                        MallAddModel addModel = await MallAddModel.fromFormData(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          openFrom: openFromController.text.trim(),
                          openTo: openToController.text.trim(),
                          zoneId:
                              int.tryParse(zoneIdController.text.trim()) ?? 0,
                          status: selectedStatus.toInt(),
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          imagePath: imagePath,
                        );
                        cubit.addData(addModel);
                      } else if (entityType == 'Service Provider') {
                        ServiceProviderAddModel addModel =
                            await ServiceProviderAddModel.fromFormData(
                          serviceId:
                              int.tryParse(serviceIdController.text.trim()) ??
                                  0,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          phone: phoneController.text.trim(),
                          status: selectedStatus.toInt(),
                          location: locationController.text.trim(),
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          imagePath: imagePath,
                          openFrom: openFromController.text.trim(),
                          openTo: openToController.text.trim(),
                          zoneId: int.tryParse(zoneIdController.text.trim()),
                          villageId:
                              int.tryParse(villageIdController.text.trim()),
                        );
                        cubit.addData(addModel);
                      } else if (entityType == 'Maintenance Provider') {
                        MaintenanceProviderAddModel addModel =
                            await MaintenanceProviderAddModel.fromFormData(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          phone: phoneController.text.trim(),
                          location: locationController.text.trim(),
                          openFrom: openFromController.text.trim(),
                          openTo: openToController.text.trim(),
                          maintenanceTypeId: selectedMaintenanceTypeId ?? 0,
                          status: selectedStatus.toInt(),
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          imagePath: imagePath,
                          villageId:
                              int.tryParse(villageIdController.text.trim()),
                        );
                        cubit.addData(addModel);
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding $entityType: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WegoColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add $entityType',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isRequired = false,
  int maxLines = 1,
  TextDirection? textDirection,
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: WegoColors.mainColor),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
