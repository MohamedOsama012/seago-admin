import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/views/Home/Widgets/custom_appBar.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';

class AddVillage extends StatefulWidget {
  const AddVillage({super.key});

  @override
  State<AddVillage> createState() => _AddVillageState();
}

class _AddVillageState extends State<AddVillage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _arNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _arDescriptionController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  int? _selectedZoneId;
  int _selectedStatus = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _arDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load zones when screen opens
    context.read<VillageCubit>().getData();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _getImage(ImageSource.camera),
                    ),
                    _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        decoration: BoxDecoration(
          color: WegoColors.mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: WegoColors.mainColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 35,
              color: WegoColors.mainColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: WegoColors.mainColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    Navigator.pop(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedImage != null
              ? WegoColors.mainColor
              : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _isLoading
            ? Container(
                color: Colors.grey.shade50,
                child: Center(
                  child: CircularProgressIndicator(
                    color: WegoColors.mainColor,
                  ),
                ),
              )
            : _selectedImage != null
                ? Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: WegoColors.mainColor.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      color: Colors.grey.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: WegoColors.mainColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 40,
                              color: WegoColors.mainColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Tap to add village image',
                            style: TextStyle(
                              color: WegoColors.mainColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'From camera or gallery',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    if (value.trim().length < 2) {
      return '$fieldName must contain at least 2 characters';
    }
    return null;
  }

  Widget _buildZoneDropdown() {
    return BlocBuilder<VillageCubit, VillageStates>(
      builder: (context, state) {
        final cubit = VillageCubit.get(context);
        return DropdownButtonFormField<int>(
          value: _selectedZoneId,
          decoration: InputDecoration(
            hintText: 'Select Zone',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide:
                  BorderSide(color: WegoColors.mainColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: WegoColors.mainColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a zone';
            }
            return null;
          },
          items: cubit.zones.map((zone) {
            return DropdownMenuItem<int>(
              value: zone.id?.toInt(),
              child: Text(zone.name ?? 'Unknown Zone'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedZoneId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildStatusSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: _selectedStatus == 1,
          onChanged: (value) {
            setState(() {
              _selectedStatus = value ? 1 : 0;
            });
          },
          activeColor: WegoColors.mainColor,
          activeTrackColor: WegoColors.mainColor.withOpacity(0.5),
        ),
        Text(
          _selectedStatus == 1 ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _saveVillage() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = VillageCubit.get(context);

    cubit.addVillage(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      arName: _arNameController.text.trim().isEmpty
          ? null
          : _arNameController.text.trim(),
      arDescription: _arDescriptionController.text.trim().isEmpty
          ? null
          : _arDescriptionController.text.trim(),
      zoneId: _selectedZoneId!,
      status: _selectedStatus,
      imagePath: _selectedImage?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Add Villages",
          style: TextStyle(
              color: WegoColors.mainColor,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(
            start: MediaQuery.of(context).size.width * 0.01,
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: WegoColors.cardColor,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: WegoColors.mainColor,
                size: 20,
              ),
            ),
          ),
        ),
        elevation: 0,
      ),
      body: BlocListener<VillageCubit, VillageStates>(
        listener: (context, state) {
          if (state is VillageAddLoadingState) {
            // Show loading
          } else if (state is VillageAddSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Village added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else if (state is VillageAddErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Image Section
                  const Text(
                    'Village Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildImageSection(),
                  const SizedBox(height: 30),

                  // Text Fields
                  _buildTextField(
                    'Village Name (English)',
                    WegoColors.mainColor,
                    controller: _nameController,
                    validator: (value) => _validateField(value, 'village name'),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    'Village Name (Arabic) - Optional',
                    WegoColors.mainColor,
                    controller: _arNameController,
                    validator: null, // Optional field
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    'Location',
                    WegoColors.mainColor,
                    controller: _locationController,
                    validator: (value) => _validateField(value, 'location'),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    'Description (English)',
                    WegoColors.mainColor,
                    controller: _descriptionController,
                    validator: (value) => _validateField(value, 'description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    'Description (Arabic) - Optional',
                    WegoColors.mainColor,
                    controller: _arDescriptionController,
                    validator: null, // Optional field
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Zone Dropdown
                  const Text(
                    'Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildZoneDropdown(),
                  const SizedBox(height: 20),

                  // Status Switch
                  _buildStatusSwitch(),
                  const SizedBox(height: 30),

                  // Save Button
                  BlocBuilder<VillageCubit, VillageStates>(
                    builder: (context, state) {
                      bool isLoading = state is VillageAddLoadingState;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveVillage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WegoColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            elevation: 2,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Village',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    Color borderColor, {
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
