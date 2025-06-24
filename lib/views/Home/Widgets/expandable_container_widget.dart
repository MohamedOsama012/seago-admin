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

// Generic model interface that any item can implement
abstract class ExpandableItem {
  String? get name;
  String? get arName;
  String? get location;
  String? get description;
  String? get arDescription;
  dynamic get id;
  dynamic get status;

  // Generic detail getters - override in implementations
  Map<String, String> get basicDetails;
  Map<String, String> get allDetails;
}

class ExpandableCard<T extends ExpandableItem> extends StatelessWidget {
  final T item;
  final int index;
  final bool isGrid;
  final bool isTablet;
  final bool isDesktop;
  final Function(int)? onExpandToggle;
  final bool isExpanded;
  final Function(T)? onEdit;
  final Function(T)? onDelete;
  final String itemTypeName; // e.g., "Village", "Mall", etc.

  const ExpandableCard({
    super.key,
    required this.item,
    required this.index,
    required this.isGrid,
    required this.isTablet,
    required this.isDesktop,
    this.onExpandToggle,
    required this.isExpanded,
    this.onEdit,
    this.onDelete,
    required this.itemTypeName,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
    final detailFontSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final buttonFontSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final cardPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Name
          Text(
            item.name ?? 'Unnamed $itemTypeName',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),

          // Details based on expansion state
          if (isGrid || isExpanded)
            ..._buildAllDetails(detailFontSize)
          else
            ..._buildBasicDetails(detailFontSize),

          // Expand/Collapse button for list view
          if (!isGrid && onExpandToggle != null) ...[
            const SizedBox(height: 45),
            GestureDetector(
              onTap: () => onExpandToggle!(index),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'Read Less' : 'Read More',
                    style: TextStyle(
                      color: WegoColors.mainColor,
                      fontSize: detailFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: WegoColors.mainColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),
          _buildActionButtons(context, buttonFontSize),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.teal,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 1,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.teal,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, double fontSize) {
    return Row(
      children: [
        if (onEdit != null)
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: ElevatedButton(
                onPressed: () {
                  print('DEBUG: Edit button pressed for ${item.name}');
                  print('DEBUG: onEdit callback = $onEdit');
                  if (onEdit != null) {
                    onEdit!(item);
                  } else {
                    print('DEBUG: onEdit is null!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WegoColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 16),
        if (onDelete != null)
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              child: OutlinedButton(
                onPressed: () => _showDeleteConfirmDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: WegoColors.mainColor,
                  side:
                      const BorderSide(color: WegoColors.mainColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: WegoColors.cardColor,
                ),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: WegoColors.mainColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete $itemTypeName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${item.name ?? 'this $itemTypeName'}"?',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone and all related data will be permanently removed.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete!(item);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildAllDetails(double fontSize) {
    final details = item.allDetails;
    return details.entries.map((entry) {
      return Column(
        children: [
          _buildDetailRow(entry.key, entry.value, fontSize),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  List<Widget> _buildBasicDetails(double fontSize) {
    final details = item.basicDetails;
    return details.entries.map((entry) {
      return Column(
        children: [
          _buildDetailRow(entry.key, entry.value, fontSize),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }
}

// Extension to make Villages compatible with ExpandableItem
extension VillageExpandableItem on Villages {
  Map<String, String> get basicDetails => {
        'Zone:': zone?.name ?? 'Not specified',
        'Population:': '${populationCount ?? 0}',
        'Units:': '${unitsCount ?? 0}',
      };

  Map<String, String> get allDetails => {
        'Zone:': zone?.name ?? 'Not specified',
        'Location:': location ?? 'Not specified',
        'Population:': '${populationCount ?? 0}',
        'Units:': '${unitsCount ?? 0}',
        'Providers:': '${providersCount ?? 0}',
        'Maintenance:': '${maintenanceProvidersCount ?? 0}',
      };
}

// Extension to make MallModel compatible with ExpandableItem
extension MallExpandableItem on MallModel {
  Map<String, String> get basicDetails => {
        'Zone:': zone.name,
        'Open From:': openFrom,
        'Open To:': openTo,
      };

  Map<String, String> get allDetails => {
        'Zone:': zone.name,
        'Description:': description,
        'AR Description:': arDescription ?? 'N/A',
        'Open From:': openFrom,
        'Open To:': openTo,
        'Status:': status == 1 ? 'Active' : 'Inactive',
        'Created:': createdAt.toString().split(' ')[0],
      };
}

// Extension to make ServiceProviderModel compatible with ExpandableItem
extension ServiceProviderExpandableItem on ServiceProviderModel {
  Map<String, String> get basicDetails => {
        'Phone:': phone,
        'Service:': service?.name ?? 'N/A',
        'Status:': status == 1 ? 'Active' : 'Inactive',
      };

  Map<String, String> get allDetails => {
        'Phone:': phone,
        'Service Type:': service?.name ?? 'N/A',
        'Location:': location ?? 'N/A',
        'Zone:': zone?.name ?? 'N/A',
        'Open From:': openFrom ?? 'N/A',
        'Open To:': openTo ?? 'N/A',
        'Rate:': rate?.toString() ?? 'N/A',
        'Status:': status == 1 ? 'Active' : 'Inactive',
        'Created:': createdAt.split(' ')[0],
      };
}

// Extension to make MaintenanceProviderModel compatible with ExpandableItem
extension MaintenanceProviderExpandableItem on MaintenanceProviderModel {
  Map<String, String> get basicDetails => {
        'Type:': type,
        'Phone:': phoneNumber,
        'Status:': isActive ? 'Active' : 'Inactive',
      };

  Map<String, String> get allDetails => {
        'Type:': type,
        'Phone Number:': phoneNumber,
        'Serving:': serving,
        'Status:': isActive ? 'Active' : 'Inactive',
        'ID:': id,
      };
}

// Generic edit dialog that adapts based on item type

void showVillageEditDialog(
    BuildContext context, Villages village, dynamic cubit) {
  final TextEditingController nameController =
      TextEditingController(text: village.name ?? '');
  final TextEditingController arNameController =
      TextEditingController(text: village.arName ?? '');
  final TextEditingController locationController =
      TextEditingController(text: village.location ?? '');
  final TextEditingController descriptionController =
      TextEditingController(text: village.description ?? '');
  final TextEditingController arDescriptionController =
      TextEditingController(text: village.arDescription ?? '');
  final TextEditingController zoneIdController =
      TextEditingController(text: village.zoneId?.toString() ?? '');

  int selectedZoneId = village.zoneId?.toInt() ?? 0;
  num? selectedStatus = village.status;
  String? imagePath;

  // Get zones data from cubit if available
  List<dynamic> availableZones = [];
  try {
    if (cubit != null && cubit.zones != null) {
      availableZones = cubit.zones;
    }
  } catch (e) {
    availableZones = [];
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Edit Village',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: WegoColors.mainColor,
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Village Name (English)',
                      icon: Icons.location_city,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: arNameController,
                      label: 'Village Name (Arabic)',
                      icon: Icons.location_city_outlined,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: descriptionController,
                      label: 'Description (English)',
                      icon: Icons.description,
                      maxLines: 3,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: arDescriptionController,
                      label: 'Description (Arabic)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: zoneIdController,
                      label: 'Zone ID',
                      icon: Icons.map,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    // Status Switch
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
                    // Image Upload Section (Optional)
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
                  // Validate required fields
                  if (nameController.text?.trim().isEmpty != false ||
                      locationController.text?.trim().isEmpty != false ||
                      descriptionController.text?.trim().isEmpty != false ||
                      selectedZoneId == 0 ||
                      selectedStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Use the generic EntityCubit interface for type-safe editing
                  try {
                    if (cubit != null) {
                      // Create edit model with all data (await the async factory method)
                      VillageEditModel editModel =
                          await VillageEditModel.fromFormData(
                        villageId: village.id ?? 0,
                        name: nameController.text?.trim() ?? '',
                        location: locationController.text?.trim() ?? '',
                        description: descriptionController.text?.trim() ?? '',
                        arName: arNameController.text?.trim() ?? '',
                        arDescription:
                            arDescriptionController.text?.trim() ?? '',
                        zoneId:
                            int.tryParse(zoneIdController.text?.trim() ?? '') ??
                                village.zoneId?.toInt() ??
                                0,
                        status: selectedStatus?.toInt() ??
                            village.status?.toInt() ??
                            0,
                        imagePath: imagePath,
                      );

                      // Call the standardized editData method from EntityCubit
                      cubit.editData(editModel);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error editing village: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  // Close dialog
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WegoColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
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

// Complete mall model for edit operations - contains all data
class MallEditModel {
  final int mallId;
  final String name;
  final String description;
  final String openFrom;
  final String openTo;
  final int zoneId;
  final int status;
  final String? arName;
  final String? arDescription;
  final String? imageBase64;

  MallEditModel({
    required this.mallId,
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

  // Factory method to create from form data with all data
  static Future<MallEditModel> fromFormData({
    required int mallId,
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
      print('DEBUG: Converting image to base64 from path: $imagePath');
      print('DEBUG: File path exists check: ${await File(imagePath).exists()}');
      imageBase64 = await _convertImageToBase64(imagePath);
      print(
          'DEBUG: Base64 conversion result - length: ${imageBase64?.length ?? 0}');
      if (imageBase64 != null) {
        print('DEBUG: Base64 conversion SUCCESS - will be included in API');
      } else {
        print('DEBUG: Base64 conversion FAILED - null result');
      }
    } else {
      print('DEBUG: No image path provided - imagePath: $imagePath');
    }

    return MallEditModel(
      mallId: mallId,
      name: name?.trim() ?? '',
      description: description?.trim() ?? '',
      openFrom: openFrom?.trim() ?? '',
      openTo: openTo?.trim() ?? '',
      zoneId: zoneId,
      status: status,
      arName: arName?.trim().isNotEmpty == true ? arName!.trim() : null,
      arDescription: arDescription?.trim().isNotEmpty == true
          ? arDescription!.trim()
          : null,
      imageBase64: imageBase64,
    );
  }

  // Check if there are any changes compared to original (for validation)
  bool hasChangesFrom(MallModel original) {
    return name != original.name ||
        description != original.description ||
        openFrom != original.openFrom ||
        openTo != original.openTo ||
        zoneId != original.zoneId ||
        status != original.status ||
        (arName ?? '') != (original.arName ?? '') ||
        (arDescription ?? '') != (original.arDescription ?? '') ||
        imageBase64 != null;
  }

  // Get the complete data for API request
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
      print(
          'DEBUG: Mall - Adding base64 image to API data - length: ${imageBase64!.length}');
    } else {
      print('DEBUG: Mall - No image data to send to API');
    }

    print('DEBUG: Final API data keys: ${data.keys.toList()}');
    return data;
  }
}

// Complete village model for edit operations - contains all data
class VillageEditModel {
  final int villageId;
  final String name;
  final String location;
  final String description;
  final String? arName;
  final String? arDescription;
  final int zoneId;
  final int status;
  final String? imageBase64;

  VillageEditModel({
    required this.villageId,
    required this.name,
    required this.location,
    required this.description,
    this.arName,
    this.arDescription,
    required this.zoneId,
    required this.status,
    this.imageBase64,
  });

  static Future<VillageEditModel> fromFormData({
    required int villageId,
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

    return VillageEditModel(
      villageId: villageId,
      name: name?.trim() ?? '',
      location: location?.trim() ?? '',
      description: description?.trim() ?? '',
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
      print(
          'DEBUG: Village - Adding base64 image to API data - length: ${imageBase64!.length}');
    } else {
      print('DEBUG: Village - No image data to send to API');
    }

    print('DEBUG: Village - Final API data keys: ${data.keys.toList()}');
    return data;
  }
}

// Complete service provider model for edit operations - contains all data
class ServiceProviderEditModel {
  final int serviceProviderId;
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

  ServiceProviderEditModel({
    required this.serviceProviderId,
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

  static Future<ServiceProviderEditModel> fromFormData({
    required int serviceProviderId,
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

    return ServiceProviderEditModel(
      serviceProviderId: serviceProviderId,
      serviceId: serviceId,
      name: name?.trim() ?? '',
      description: description?.trim() ?? '',
      phone: phone?.trim() ?? '',
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
      'service_id':
          serviceId, // This should be the service type ID, not the provider ID
      'name': name.isNotEmpty ? name : '',
      'description': description.isNotEmpty ? description : '',
      'phone': phone.isNotEmpty ? phone : '',
      'status': status,
    };

    // Always include location (required field)
    data['location'] = location?.isNotEmpty == true ? location! : '';

    // Always include ar_name (even if empty)
    data['ar_name'] = arName?.isNotEmpty == true ? arName! : '';

    // Always include ar_description (even if empty)
    data['ar_description'] =
        arDescription?.isNotEmpty == true ? arDescription! : '';

    // Always include open_from (even if empty)
    data['open_from'] = openFrom?.isNotEmpty == true ? openFrom! : '';

    // Always include open_to (even if empty)
    data['open_to'] = openTo?.isNotEmpty == true ? openTo! : '';

    // Include village_id only if it has a valid value
    if (villageId != null && villageId! > 0) {
      data['village_id'] = villageId;
    }

    // Include zone_id only if it has a valid value
    if (zoneId != null && zoneId! > 0) {
      data['zone_id'] = zoneId;
    }

    // Always provide location_map (temporary until backend handles automatically)
    data['location_map'] = locationMap?.isNotEmpty == true
        ? locationMap!
        : 'https://maps.google.com';

    // Image handling: Only include the image if a new one was selected.
    // Otherwise, the backend will keep the existing image.
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      print(
          'DEBUG: ServiceProvider - Adding selected base64 image to API data - length: ${imageBase64!.length}');
    } else {
      print(
          'DEBUG: ServiceProvider - No new image selected. Existing image will be preserved on the server.');
    }

    print('DEBUG: ServiceProvider - Final API data:');
    print('DEBUG: serviceProviderId (for URL): $serviceProviderId');
    print('DEBUG: serviceId (in body): $serviceId');
    data.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });

    return data;
  }
}

// Complete maintenance provider model for edit operations - contains all data
class MaintenanceProviderEditModel {
  final int maintenanceProviderId;
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

  MaintenanceProviderEditModel({
    required this.maintenanceProviderId,
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

  static Future<MaintenanceProviderEditModel> fromFormData({
    required int maintenanceProviderId,
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

    return MaintenanceProviderEditModel(
      maintenanceProviderId: maintenanceProviderId,
      name: name?.trim() ?? '',
      description: description?.trim() ?? '',
      phone: phone?.trim() ?? '',
      location: location?.trim() ?? '',
      openFrom: openFrom?.trim() ?? '',
      openTo: openTo?.trim() ?? '',
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

    if (villageId != null) {
      data['village_id'] = villageId;
    }

    // Image handling: Only include the image if a new one was selected
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = _ensureDataUrlPrefix(imageBase64!);
      print(
          'DEBUG: MaintenanceProvider - Adding selected base64 image to API data - length: ${imageBase64!.length}');
    } else {
      print(
          'DEBUG: MaintenanceProvider - No new image selected. Existing image will be preserved on the server.');
    }

    print('DEBUG: MaintenanceProvider - Final API data:');
    print('DEBUG: maintenanceProviderId (for URL): $maintenanceProviderId');
    print('DEBUG: maintenanceTypeId (in body): $maintenanceTypeId');
    print('DEBUG: villageId (in body): $villageId');
    data.forEach((key, value) {
      print('  $key: $value (${value.runtimeType})');
    });

    return data;
  }
}

void showEditDialog(BuildContext context, dynamic item, dynamic cubit) {
  print('DEBUG: showEditDialog called with item type: ${item.runtimeType}');
  print('DEBUG: item.name: ${item.name}');
  print('DEBUG: cubit type: ${cubit.runtimeType}');

  // Determine entity type
  String entityType = '';
  if (item is Villages) {
    entityType = 'Village';
  } else if (item is ServiceProviderModel) {
    entityType = 'Service Provider';
  } else if (item is Providers) {
    entityType = 'Maintenance Provider';
  } else if (item is MallModel) {
    entityType = 'Mall';
  }

  print('DEBUG: Determined entityType: $entityType');

  // Initialize controllers with item data
  print('DEBUG: Initializing controllers...');

  final TextEditingController nameController =
      TextEditingController(text: item.name ?? '');
  print('DEBUG: nameController initialized');

  final TextEditingController arNameController =
      TextEditingController(text: item.arName ?? '');
  print('DEBUG: arNameController initialized');

  final TextEditingController descriptionController =
      TextEditingController(text: item.description ?? '');
  print('DEBUG: descriptionController initialized');

  final TextEditingController arDescriptionController =
      TextEditingController(text: item.arDescription ?? '');
  print('DEBUG: arDescriptionController initialized');

  final TextEditingController locationController = TextEditingController(
      text: (item is Villages ||
              item is ServiceProviderModel ||
              item is Providers)
          ? item.location ?? ''
          : '');
  print('DEBUG: locationController initialized');

  // Entity-specific controllers
  final TextEditingController phoneController = TextEditingController(
      text: (item is ServiceProviderModel || item is Providers)
          ? (item is ServiceProviderModel ? item.phone : item.phone)
          : '');
  print('DEBUG: phoneController initialized');

  final TextEditingController openFromController = TextEditingController(
      text: (item is ServiceProviderModel ||
              item is Providers ||
              item is MallModel)
          ? item.openFrom ?? ''
          : '');
  print('DEBUG: openFromController initialized');

  final TextEditingController openToController = TextEditingController(
      text: (item is ServiceProviderModel ||
              item is Providers ||
              item is MallModel)
          ? item.openTo ?? ''
          : '');
  print('DEBUG: openToController initialized');

  // Entity-specific controllers
  final TextEditingController zoneIdController = TextEditingController(
      text: (item is Villages ||
              item is MallModel ||
              item is ServiceProviderModel)
          ? (item.zoneId?.toString() ?? '')
          : '');
  print('DEBUG: zoneIdController initialized');

  final TextEditingController villageIdController = TextEditingController(
      text: (item is ServiceProviderModel || item is Providers)
          ? (item.villageId?.toString() ?? '')
          : '');
  print('DEBUG: villageIdController initialized');

  final TextEditingController serviceIdController = TextEditingController(
      text: item is ServiceProviderModel
          ? (item.serviceId?.toString() ?? '')
          : '');
  print('DEBUG: serviceIdController initialized');

  // Status handling
  print('DEBUG: Handling status...');
  num? selectedStatus;
  if (item is Villages || item is ServiceProviderModel || item is MallModel) {
    selectedStatus = item.status;
  } else if (item is Providers) {
    selectedStatus = item.status;
  }
  print('DEBUG: selectedStatus = $selectedStatus');

  // Maintenance type handling for maintenance providers
  int? selectedMaintenanceTypeId;
  if (item is Providers) {
    selectedMaintenanceTypeId = item.maintenanceTypeId?.toInt();
  }
  print('DEBUG: selectedMaintenanceTypeId = $selectedMaintenanceTypeId');

  String? imagePath;
  print('DEBUG: All controllers and variables initialized successfully');

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Edit $entityType',
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
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Zone ID - Service Provider only
                    if (entityType == 'Service Provider') ...[
                      _buildTextField(
                        controller: zoneIdController,
                        label: 'Zone ID',
                        icon: Icons.map,
                        isRequired: true,
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
                      descriptionController.text.trim().isEmpty ||
                      selectedStatus == null) {
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
                          villageIdController.text.trim().isEmpty ||
                          zoneIdController.text.trim().isEmpty ||
                          serviceIdController.text.trim().isEmpty)) {
                    isValid = false;
                    errorMessage =
                        'All fields are required for service provider';
                  }

                  if (entityType == 'Maintenance Provider' &&
                      (phoneController.text.trim().isEmpty ||
                          openFromController.text.trim().isEmpty ||
                          openToController.text.trim().isEmpty ||
                          locationController.text.trim().isEmpty ||
                          selectedMaintenanceTypeId == null)) {
                    isValid = false;
                    errorMessage =
                        'All fields are required for maintenance provider';
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
                      // Create appropriate edit model based on entity type
                      if (entityType == 'Village') {
                        VillageEditModel editModel =
                            await VillageEditModel.fromFormData(
                          villageId: item.id ?? 0,
                          name: nameController.text.trim(),
                          location: locationController.text.trim(),
                          description: descriptionController.text.trim(),
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          zoneId:
                              int.tryParse(zoneIdController.text.trim()) ?? 0,
                          status: selectedStatus?.toInt() ?? 0,
                          imagePath: imagePath,
                        );
                        cubit.editData(editModel);
                      } else if (entityType == 'Mall') {
                        MallEditModel editModel =
                            await MallEditModel.fromFormData(
                          mallId: item.id,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          openFrom: openFromController.text.trim(),
                          openTo: openToController.text.trim(),
                          zoneId: int.tryParse(zoneIdController.text.trim()) ??
                              item.zoneId,
                          status: selectedStatus?.toInt() ?? 0,
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          imagePath: imagePath,
                        );
                        cubit.editData(editModel);
                      } else if (entityType == 'Service Provider') {
                        print(
                            'DEBUG: Original item.serviceId: ${item.serviceId}');
                        print(
                            'DEBUG: Form serviceIdController: ${serviceIdController.text.trim()}');
                        print('DEBUG: item.id (provider ID): ${item.id}');

                        ServiceProviderEditModel editModel =
                            await ServiceProviderEditModel.fromFormData(
                          serviceProviderId: item.id,
                          serviceId:
                              int.tryParse(serviceIdController.text.trim()) ??
                                  item.serviceId,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          phone: phoneController.text.trim(),
                          status: selectedStatus?.toInt() ?? 0,
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
                        cubit.editData(editModel);
                      } else if (entityType == 'Maintenance Provider') {
                        MaintenanceProviderEditModel editModel =
                            await MaintenanceProviderEditModel.fromFormData(
                          maintenanceProviderId: item.id,
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          phone: phoneController.text.trim(),
                          location: locationController.text.trim(),
                          openFrom: openFromController.text.trim(),
                          openTo: openToController.text.trim(),
                          maintenanceTypeId: selectedMaintenanceTypeId ?? 0,
                          status: selectedStatus?.toInt() ?? 0,
                          arName: arNameController.text.trim(),
                          arDescription: arDescriptionController.text.trim(),
                          imagePath: imagePath,
                          villageId:
                              int.tryParse(villageIdController.text.trim()),
                        );
                        cubit.editData(editModel);
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error editing $entityType: $e'),
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
                child: const Text(
                  'Save Changes',
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

void showServiceProviderEditDialog(
    BuildContext context, ServiceProviderModel serviceProvider, dynamic cubit) {
  // Implementation for service provider edit dialog with all required fields
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content:
          Text('Service Provider edit dialog - implementation in progress'),
      backgroundColor: Colors.orange,
    ),
  );
}

void showMaintenanceProviderEditDialog(BuildContext context,
    MaintenanceProviderModel maintenanceProvider, dynamic cubit) {
  // Implementation for maintenance provider edit dialog
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content:
          Text('Maintenance Provider edit dialog - implementation in progress'),
      backgroundColor: Colors.orange,
    ),
  );
}

void showGenericEditDialog(
    BuildContext context, dynamic item, String itemType, dynamic cubit) {
  // Generic fallback edit dialog
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Edit dialog for $itemType - implementation needed'),
      backgroundColor: Colors.blue,
    ),
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

// Wrapper class for Villages to implement ExpandableItem
class VillageItem implements ExpandableItem {
  final Villages _village;

  VillageItem(this._village);

  @override
  String? get name => _village.name;

  @override
  String? get arName => _village.arName;

  @override
  String? get location => _village.location;

  @override
  String? get description => _village.description;

  @override
  String? get arDescription => _village.arDescription;

  @override
  dynamic get id => _village.id;

  @override
  dynamic get status => _village.status;

  @override
  Map<String, String> get basicDetails => _village.basicDetails;

  @override
  Map<String, String> get allDetails => _village.allDetails;

  // Getter to access the original village object
  Villages get village => _village;
}

// Wrapper class for MallModel to implement ExpandableItem
class MallItem implements ExpandableItem {
  final MallModel _mall;

  MallItem(this._mall);

  @override
  String? get name => _mall.name;

  @override
  String? get arName => _mall.arName;

  @override
  String? get location => null; // MallModel doesn't have location field

  @override
  String? get description => _mall.description;

  @override
  String? get arDescription => _mall.arDescription;

  @override
  dynamic get id => _mall.id;

  @override
  dynamic get status => _mall.status;

  @override
  Map<String, String> get basicDetails => _mall.basicDetails;

  @override
  Map<String, String> get allDetails => _mall.allDetails;

  // Getter to access the original mall object
  MallModel get mall => _mall;
}

// Wrapper class for ServiceProviderModel to implement ExpandableItem
class ServiceProviderItem implements ExpandableItem {
  final ServiceProviderModel _serviceProvider;

  ServiceProviderItem(this._serviceProvider);

  @override
  String? get name => _serviceProvider.name;

  @override
  String? get arName => _serviceProvider.arName;

  @override
  String? get location => _serviceProvider.location;

  @override
  String? get description => _serviceProvider.description;

  @override
  String? get arDescription => _serviceProvider.arDescription;

  @override
  dynamic get id => _serviceProvider.id;

  @override
  dynamic get status => _serviceProvider.status;

  @override
  Map<String, String> get basicDetails => _serviceProvider.basicDetails;

  @override
  Map<String, String> get allDetails => _serviceProvider.allDetails;

  // Getter to access the original service provider object
  ServiceProviderModel get serviceProvider => _serviceProvider;
}

// Wrapper class for MaintenanceProviderModel to implement ExpandableItem
class MaintenanceProviderItem implements ExpandableItem {
  final Providers _maintenanceProvider;

  MaintenanceProviderItem(this._maintenanceProvider);

  @override
  String? get name => _maintenanceProvider.name;

  @override
  String? get arName => _maintenanceProvider.arName;

  @override
  String? get location => _maintenanceProvider.location;

  @override
  String? get description => _maintenanceProvider.description;

  @override
  String? get arDescription => _maintenanceProvider.arDescription;

  @override
  dynamic get id => _maintenanceProvider.id;

  @override
  dynamic get status => _maintenanceProvider.status;

  @override
  Map<String, String> get basicDetails => {
        'Phone:': _maintenanceProvider.phone ?? 'N/A',
        'Status:': _maintenanceProvider.status == 1 ? 'Active' : 'Inactive',
      };

  @override
  Map<String, String> get allDetails => {
        'Phone:': _maintenanceProvider.phone ?? 'N/A',
        'Location:': _maintenanceProvider.location ?? 'N/A',
        'Open From:': _maintenanceProvider.openFrom ?? 'N/A',
        'Open To:': _maintenanceProvider.openTo ?? 'N/A',
        'Status:': _maintenanceProvider.status == 1 ? 'Active' : 'Inactive',
      };

  // Getter to access the original maintenance provider object
  Providers get maintenanceProvider => _maintenanceProvider;
}
