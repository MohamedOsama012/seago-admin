import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';
import 'package:sa7el/Model/village_model.dart';

class VillageList extends StatefulWidget {
  const VillageList({super.key});

  @override
  State<VillageList> createState() => _VillageListState();
}

class _VillageListState extends State<VillageList>
    with AutomaticKeepAliveClientMixin {
  Map<int, bool> expandedStates = {};
  ScrollController? _scrollController;
  bool _isInitialized = false;

  // Cache for responsive values
  late double _screenWidth;
  late double _screenHeight;
  late bool _isTablet;
  late bool _isDesktop;
  late double _horizontalPadding;
  late double _cardHeight;

  @override
  bool get wantKeepAlive => true; // Keep state alive

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Load data only once
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVillages();
      });
    }
  }

  void _loadVillages() {
    final cubit = context.read<VillageCubit>();
    if (cubit.filteredVillages.isEmpty) {
      cubit.getData();
    }
    _isInitialized = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateResponsiveValues();
  }

  void _updateResponsiveValues() {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _isTablet = _screenWidth >= 768;
    _isDesktop = _screenWidth >= 1024;
    _horizontalPadding = _isDesktop ? 32.0 : (_isTablet ? 24.0 : 16.0);
    _cardHeight = _isDesktop
        ? _screenHeight * 0.32
        : (_isTablet ? _screenHeight * 0.3 : _screenHeight * 0.27);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return BlocConsumer<VillageCubit, VillageStates>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final cubit = VillageCubit.get(context);
        return _buildVillageContent(context, state, cubit);
      },
    );
  }

  void _handleStateChanges(BuildContext context, VillageStates state) {
    final messenger = ScaffoldMessenger.of(context);

    switch (state.runtimeType) {
      case VillageErrorState:
        final errorState = state as VillageErrorState;
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorState.error),
            backgroundColor: Colors.red,
          ),
        );
        break;
      case VillageDeleteSuccessState:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Village deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case VillageDeleteErrorState:
        final errorState = state as VillageDeleteErrorState;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error deleting village: ${errorState.error}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        break;
    }
  }

  Widget _buildVillageContent(
      BuildContext context, VillageStates state, VillageCubit cubit) {
    if (state is VillaLoadingState) {
      return Center(
        child: CircularProgressIndicator(color: WegoColors.mainColor),
      );
    }

    if (cubit.filteredVillages.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isDesktop || _isTablet) {
          return _buildOptimizedGridLayout(cubit);
        }
        return _buildOptimizedListLayout(cubit);
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No villages available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Optimized Grid Layout with lazy building
  Widget _buildOptimizedGridLayout(VillageCubit cubit) {
    final crossAxisCount = _isDesktop ? 3 : 2;
    final childAspectRatio = _isDesktop ? 1.2 : 1.1;
    final villages = cubit.filteredVillages;

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 32.0 : 24.0,
        vertical: 16.0,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 20.0,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: villages.length,
      cacheExtent: 200, // Cache items outside viewport
      itemBuilder: (context, index) {
        return VillageCard(
          key: ValueKey(villages[index].id),
          village: villages[index],
          index: index,
          isGrid: true,
          isTablet: _isTablet,
          isDesktop: _isDesktop,
          onExpandToggle: null,
          isExpanded: false,
        );
      },
    );
  }

  // Optimized List Layout with lazy building
  Widget _buildOptimizedListLayout(VillageCubit cubit) {
    final villages = cubit.filteredVillages;

    return ListView.builder(
      controller: _scrollController,
      itemCount: villages.length,
      padding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      cacheExtent: 500, // Cache more items for smoother scrolling
      itemBuilder: (context, index) {
        final isExpanded = expandedStates[index] ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? null : _cardHeight,
          margin: const EdgeInsets.only(bottom: 20),
          child: VillageCard(
            key: ValueKey(villages[index].id),
            village: villages[index],
            index: index,
            isGrid: false,
            isTablet: _isTablet,
            isDesktop: _isDesktop,
            onExpandToggle: (index) {
              setState(() {
                expandedStates[index] = !isExpanded;
              });
            },
            isExpanded: isExpanded,
          ),
        );
      },
    );
  }
}

// Separate Widget for Village Card to optimize rebuilds
class VillageCard extends StatelessWidget {
  final Villages village;
  final int index;
  final bool isGrid;
  final bool isTablet;
  final bool isDesktop;
  final Function(int)? onExpandToggle;
  final bool isExpanded;

  const VillageCard({
    super.key,
    required this.village,
    required this.index,
    required this.isGrid,
    required this.isTablet,
    required this.isDesktop,
    this.onExpandToggle,
    required this.isExpanded,
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
          // Village Name
          Text(
            village.name ?? 'Unnamed Village',
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

  List<Widget> _buildAllDetails(double fontSize) {
    return [
      _buildDetailRow('Zone:', village.zone?.name ?? 'Not specified', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow(
          'Location:', village.location ?? 'Not specified', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow(
          'Population:', '${village.populationCount ?? 0}', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow('Units:', '${village.unitsCount ?? 0}', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow('Providers:', '${village.providersCount ?? 0}', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow('Maintenance:',
          '${village.maintenanceProvidersCount ?? 0}', fontSize),
    ];
  }

  List<Widget> _buildBasicDetails(double fontSize) {
    return [
      _buildDetailRow('Zone:', village.zone?.name ?? 'Not specified', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow(
          'Population:', '${village.populationCount ?? 0}', fontSize),
      SizedBox(height: isDesktop ? 12 : 8),
      _buildDetailRow('Units:', '${village.unitsCount ?? 0}', fontSize),
    ];
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
    final buttonPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
    final buttonSpacing = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            child: ElevatedButton(
              onPressed: () => _showEditDialog(context, village),
              style: ElevatedButton.styleFrom(
                backgroundColor: WegoColors.mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
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
        SizedBox(width: buttonSpacing),
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            child: OutlinedButton(
              onPressed: () => _showDeleteConfirmDialog(context, village),
              style: OutlinedButton.styleFrom(
                foregroundColor: WegoColors.mainColor,
                side: const BorderSide(color: WegoColors.mainColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                backgroundColor: Colors.white,
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

  void _showEditDialog(BuildContext context, Villages village) {
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

    int selectedZoneId = village.zoneId?.toInt() ?? 0;
    num? selectedStatus = village.status;
    String? imagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocConsumer<VillageCubit, VillageStates>(
              listener: (context, state) {
                if (state is VillageEditSuccessState) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Village updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is VillageEditErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final cubit = VillageCubit.get(context);
                final isLoading = state is VillageEditLoadingState;

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
                          // Zone Selection
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<int>(
                              value:
                                  selectedZoneId == 0 ? null : selectedZoneId,
                              decoration: const InputDecoration(
                                labelText: 'Select Zone *',
                                prefixIcon: Icon(Icons.map,
                                    color: WegoColors.mainColor),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              items: cubit.zones.map((zone) {
                                return DropdownMenuItem<int>(
                                  value: zone.id?.toInt(),
                                  child: Text(zone.name ?? 'Unnamed Zone'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedZoneId = value ?? 0;
                                });
                              },
                              validator: (value) {
                                if (value == null || value == 0) {
                                  return 'Please select a zone';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Status Switch
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.toggle_on,
                                      color: WegoColors.mainColor),
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
                            child: ListTile(
                              leading: const Icon(Icons.image,
                                  color: WegoColors.mainColor),
                              title: Text(imagePath != null
                                  ? 'Image Selected'
                                  : 'Select Image (Optional)'),
                              subtitle: imagePath != null
                                  ? Text(imagePath!.split('/').last)
                                  : null,
                              trailing: const Icon(Icons.upload_file),
                              onTap: () {
                                // Image Picker
                                // _pickImage().then((path) {
                                //   if (path != null) {
                                //     setState(() {
                                //       imagePath = path;
                                //     });
                                //   }
                                // });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.of(dialogContext).pop();
                            },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              _saveVillageChanges(
                                context,
                                village.id?.toInt() ?? 0,
                                nameController.text,
                                locationController.text,
                                descriptionController.text,
                                arNameController.text,
                                arDescriptionController.text,
                                selectedZoneId,
                                selectedStatus!.toInt(),
                                imagePath,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WegoColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Villages village) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<VillageCubit, VillageStates>(
          listener: (context, state) {
            if (state is VillageDeleteSuccessState) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Village "${village.name}" deleted successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else if (state is VillageDeleteErrorState) {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting village: ${state.error}'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = VillageCubit.get(context);
            final isLoading = state is VillageDeleteLoadingState;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Delete Village',
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
                    'Are you sure you want to delete "${village.name ?? 'this village'}"?',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'This action cannot be undone and all related data will be permanently removed.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (isLoading) ...[
                    SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: WegoColors.mainColor,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Deleting village...',
                          style: TextStyle(
                            color: WegoColors.mainColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isLoading ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          cubit.deleteData(village.id?.toInt() ?? 0);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
          labelText: label + (isRequired ? ' *' : ''),
          prefixIcon: Icon(icon, color: WegoColors.mainColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  void _saveVillageChanges(
    BuildContext context,
    int villageId,
    String name,
    String location,
    String description,
    String? arName,
    String? arDescription,
    int zoneId,
    int status,
    String? imagePath,
  ) {
    if (name.trim().isEmpty ||
        location.trim().isEmpty ||
        description.trim().isEmpty ||
        zoneId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cubit = VillageCubit.get(context);
    cubit.editVillage(
      villageId: villageId,
      name: name.trim(),
      location: location.trim(),
      description: description.trim(),
      arName: arName?.trim(),
      arDescription: arDescription?.trim(),
      zoneId: zoneId,
      status: status,
      imagePath: imagePath,
    );
  }
}
