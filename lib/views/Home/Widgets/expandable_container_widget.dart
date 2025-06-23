import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Model/village_model.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Model/service_provider_model.dart';
import 'package:sa7el/Model/maintenance_provider_model.dart';
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
    File imageFile = File(imagePath);
    if (await imageFile.exists()) {
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      return base64String;
    } else {
      print('Image file does not exist: $imagePath');
      return null;
    }
  } catch (e) {
    print('Error converting image to base64: $e');
    return null;
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
void showEditDialog<T extends ExpandableItem>(
    BuildContext context, T item, String itemType, dynamic cubit) {
  // Debug prints to help identify the issue
  print('DEBUG: showEditDialog called');
  print('DEBUG: itemType = $itemType');
  print('DEBUG: item type = ${item.runtimeType}');
  print('DEBUG: item is VillageItem = ${item is VillageItem}');
  print('DEBUG: item is MallItem = ${item is MallItem}');
  print('DEBUG: cubit = $cubit');

  if (itemType == 'Village' && item is VillageItem) {
    print('DEBUG: Calling showVillageEditDialog');
    showVillageEditDialog(context, item.village, cubit);
  } else if (itemType == 'Mall' && item is MallItem) {
    print('DEBUG: Calling showMallEditDialog');
    showMallEditDialog(context, item.mall, cubit);
  } else if (itemType == 'Service Provider' && item is ServiceProviderItem) {
    print('DEBUG: Calling showServiceProviderEditDialog');
    showServiceProviderEditDialog(context, item.serviceProvider, cubit);
  } else if (itemType == 'Maintenance Provider' &&
      item is MaintenanceProviderItem) {
    print('DEBUG: Calling showMaintenanceProviderEditDialog');
    showMaintenanceProviderEditDialog(context, item.maintenanceProvider, cubit);
  } else {
    print('DEBUG: Calling showGenericEditDialog (fallback)');
    // Fallback generic dialog
    showGenericEditDialog(context, item, itemType, cubit);
  }
}

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
                onPressed: () {
                  // Validate required fields
                  if (nameController.text.trim().isEmpty ||
                      locationController.text.trim().isEmpty ||
                      descriptionController.text.trim().isEmpty ||
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
                      // Create updated village model with form data
                      Villages updatedVillage = Villages(
                        id: village.id,
                        name: nameController.text.trim(),
                        arName: arNameController.text.trim().isNotEmpty
                            ? arNameController.text.trim()
                            : village.arName,
                        location: locationController.text.trim(),
                        description: descriptionController.text.trim(),
                        arDescription:
                            arDescriptionController.text.trim().isNotEmpty
                                ? arDescriptionController.text.trim()
                                : village.arDescription,
                        zoneId: int.tryParse(zoneIdController.text.trim()) ??
                            village.zoneId,
                        status: selectedStatus?.toInt() ?? village.status,
                        image: imagePath ?? village.image,
                      );

                      // Call the standardized editData method from EntityCubit
                      cubit.editData(updatedVillage);
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
      imageBase64 = await _convertImageToBase64(imagePath);
    }

    return MallEditModel(
      mallId: mallId,
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
      data['image'] = imageBase64;
    }

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
      data['image'] = imageBase64;
    }

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

    if (location != null && location!.isNotEmpty) {
      data['location'] = location;
    }

    if (arName != null && arName!.isNotEmpty) {
      data['ar_name'] = arName;
    }

    if (arDescription != null && arDescription!.isNotEmpty) {
      data['ar_description'] = arDescription;
    }

    if (openFrom != null && openFrom!.isNotEmpty) {
      data['open_from'] = openFrom;
    }

    if (openTo != null && openTo!.isNotEmpty) {
      data['open_to'] = openTo;
    }

    if (zoneId != null) {
      data['zone_id'] = zoneId;
    }

    if (villageId != null) {
      data['village_id'] = villageId;
    }

    if (locationMap != null && locationMap!.isNotEmpty) {
      data['location_map'] = locationMap;
    }

    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      data['image'] = imageBase64;
    }

    return data;
  }
}

// Complete maintenance provider model for edit operations - contains all data

void showMallEditDialog(BuildContext context, MallModel mall, dynamic cubit) {
  final TextEditingController nameController =
      TextEditingController(text: mall.name);
  final TextEditingController arNameController =
      TextEditingController(text: mall.arName);
  final TextEditingController descriptionController =
      TextEditingController(text: mall.description);
  final TextEditingController arDescriptionController =
      TextEditingController(text: mall.arDescription);
  final TextEditingController openFromController =
      TextEditingController(text: mall.openFrom);
  final TextEditingController openToController =
      TextEditingController(text: mall.openTo);
  final TextEditingController zoneIdController =
      TextEditingController(text: mall.zoneId.toString());

  int selectedZoneId = mall.zoneId;
  num? selectedStatus = mall.status;
  String? imagePath;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Edit Mall',
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
                      label: 'Mall Name (English)',
                      icon: Icons.store,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: arNameController,
                      label: 'Mall Name (Arabic)',
                      icon: Icons.store_outlined,
                      textDirection: TextDirection.rtl,
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
                      controller: openFromController,
                      label: 'Open From',
                      icon: Icons.access_time,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: openToController,
                      label: 'Open To',
                      icon: Icons.access_time_filled,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: zoneIdController,
                      label: 'Zone ID',
                      icon: Icons.map,
                      isRequired: true,
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
                  try {
                    if (cubit != null) {
                      // Create edit model with all data (await the async factory method)

                      MallEditModel editModel =
                          await MallEditModel.fromFormData(
                        mallId: mall.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        openFrom: openFromController.text.trim(),
                        openTo: openToController.text.trim(),
                        zoneId: int.tryParse(zoneIdController.text.trim()) ??
                            mall.zoneId,
                        status: selectedStatus?.toInt() ?? mall.status,
                        arName: arNameController.text.trim(),
                        arDescription: arDescriptionController.text.trim(),
                        imagePath: imagePath,
                      );

                      // Call editData with complete model
                      cubit.editData(editModel);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error editing mall: $e'),
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
  final MaintenanceProviderModel _maintenanceProvider;

  MaintenanceProviderItem(this._maintenanceProvider);

  @override
  String? get name => _maintenanceProvider.name;

  @override
  String? get arName => null; // MaintenanceProviderModel doesn't have arName

  @override
  String? get location =>
      null; // MaintenanceProviderModel doesn't have location

  @override
  String? get description =>
      null; // MaintenanceProviderModel doesn't have description

  @override
  String? get arDescription =>
      null; // MaintenanceProviderModel doesn't have arDescription

  @override
  dynamic get id => _maintenanceProvider.id;

  @override
  dynamic get status => _maintenanceProvider.isActive;

  @override
  Map<String, String> get basicDetails => _maintenanceProvider.basicDetails;

  @override
  Map<String, String> get allDetails => _maintenanceProvider.allDetails;

  // Getter to access the original maintenance provider object
  MaintenanceProviderModel get maintenanceProvider => _maintenanceProvider;
}

/*
USAGE EXAMPLES:

// For Villages:
ExpandableCard<VillageItem>(
  item: VillageItem(villageData),
  index: 0,
  isGrid: false,
  isTablet: false,
  isDesktop: false,
  isExpanded: false,
  itemTypeName: 'Village',
  onEdit: (villageItem) {
    showEditDialog(context, villageItem, 'Village', cubit);
  },
  onDelete: (villageItem) {
    cubit.deleteData(villageItem.id);
  },
  onExpandToggle: (index) {
    setState(() {
      expandedItems[index] = !expandedItems[index];
    });
  },
)

// For Malls:
ExpandableCard<MallItem>(
  item: MallItem(mallData),
  index: 0,
  isGrid: false,
  isTablet: false,
  isDesktop: false,
  isExpanded: false,
  itemTypeName: 'Mall',
  onEdit: (mallItem) {
    showEditDialog(context, mallItem, 'Mall', cubit);
  },
  onDelete: (mallItem) {
    cubit.deleteData(mallItem.id);
  },
)

// For Service Providers:
ExpandableCard<ServiceProviderItem>(
  item: ServiceProviderItem(serviceProviderData),
  index: 0,
  isGrid: false,
  isTablet: false,
  isDesktop: false,
  isExpanded: true,
  itemTypeName: 'Service Provider',
  onEdit: (serviceProviderItem) {
    showEditDialog(context, serviceProviderItem, 'Service Provider', cubit);
  },
  onDelete: (serviceProviderItem) {
    cubit.deleteData(serviceProviderItem.id);
  },
)

// For Maintenance Providers:
ExpandableCard<MaintenanceProviderItem>(
  item: MaintenanceProviderItem(maintenanceProviderData),
  index: 0,
  isGrid: false,
  isTablet: false,
  isDesktop: false,
  isExpanded: false,
  itemTypeName: 'Maintenance Provider',
  onEdit: (maintenanceProviderItem) {
    showEditDialog(context, maintenanceProviderItem, 'Maintenance Provider', cubit);
  },
  onDelete: (maintenanceProviderItem) {
    cubit.deleteData(maintenanceProviderItem.id);
  },
)

// Generic usage with any type:
Widget buildExpandableCard<T extends ExpandableItem>(
  T item, 
  String itemType, 
  int index, 
  dynamic cubit
) {
  return ExpandableCard<T>(
    item: item,
    index: index,
    isGrid: false,
    isTablet: false,
    isDesktop: false,
    isExpanded: false,
    itemTypeName: itemType,
    onEdit: (item) => showEditDialog(context, item, itemType, cubit),
    onDelete: (item) => cubit.deleteData(item.id),
  );
}

// For custom items, create your own class implementing ExpandableItem interface
*/
