import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/text_styles.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';

class editMallsAlertDialog extends StatefulWidget {
  final MallModel mallModel;

  const editMallsAlertDialog({Key? key, required this.mallModel})
      : super(key: key);

  @override
  State<editMallsAlertDialog> createState() => _editMallsAlertDialogState();
}

class _editMallsAlertDialogState extends State<editMallsAlertDialog> {
  late TextEditingController nameController;
  late TextEditingController arNameController;
  late TextEditingController descriptionController;
  late TextEditingController arDescriptionController;
  late TextEditingController openFromController;
  late TextEditingController openToController;
  late TextEditingController locationController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int selectedZoneId = 0;
  num? selectedStatus;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current mall data
    nameController = TextEditingController(text: widget.mallModel.name ?? '');
    arNameController =
        TextEditingController(text: widget.mallModel.arName ?? '');
    descriptionController =
        TextEditingController(text: widget.mallModel.description ?? '');
    arDescriptionController =
        TextEditingController(text: widget.mallModel.arDescription ?? '');
    openFromController =
        TextEditingController(text: widget.mallModel.openFrom ?? '');
    openToController =
        TextEditingController(text: widget.mallModel.openTo ?? '');
    locationController = TextEditingController();

    // Initialize selection values
    selectedZoneId = widget.mallModel.zone?.id?.toInt() ?? 0;
    selectedStatus = widget.mallModel.status;
  }

  @override
  void dispose() {
    nameController.dispose();
    arNameController.dispose();
    descriptionController.dispose();
    arDescriptionController.dispose();
    openFromController.dispose();
    openToController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MallsCubit, MallsStates>(
      listener: (context, state) {
        if (state is MallsEditSuccessState) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is MallsEditFailedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = MallsCubit.get(context);
        final isLoading = state is MallsEditLoadingState;

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
              child: Form(
                key: _formKey,
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
                    ),
                    const SizedBox(height: 16),
                    // Operating Hours Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: openFromController,
                            label: 'Open From',
                            icon: Icons.access_time,
                            isRequired: true,
                            hintText: 'HH:MM:SS',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: openToController,
                            label: 'Open To',
                            icon: Icons.access_time_filled,
                            isRequired: true,
                            hintText: 'HH:MM:SS',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Zone Selection - Only show if zones are available

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
                          // Image Picker implementation
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
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : _saveMall,
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    TextDirection? textDirection,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          hintText: hintText,
          prefixIcon: Icon(icon, color: WegoColors.mainColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return 'This field is required';
          }
          if (label.contains('Open From') || label.contains('Open To')) {
            if (value != null &&
                value.isNotEmpty &&
                !_isValidTimeFormat(value)) {
              return 'Please enter valid time format (HH:MM:SS)';
            }
          }
          return null;
        },
      ),
    );
  }

  bool _isValidTimeFormat(String time) {
    try {
      final RegExp timeRegex =
          RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$');
      return timeRegex.hasMatch(time);
    } catch (e) {
      return false;
    }
  }

  void _saveMall() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        openFromController.text.trim().isEmpty ||
        openToController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // final cubit = MallsCubit.get(context);
    // cubit.editData(
    //   mallId: widget.mallModel.id,
    //   name: nameController.text.trim(),
    //   openFrom: openFromController.text.trim(),
    //   openTo: openToController.text.trim(),
    //   description: descriptionController.text.trim(),
    //   arName: arNameController.text.trim().isNotEmpty
    //       ? arNameController.text.trim()
    //       : null,
    //   arDescription: arDescriptionController.text.trim().isNotEmpty
    //       ? arDescriptionController.text.trim()
    //       : null,
    //   zoneId: selectedZoneId != 0 ? selectedZoneId : widget.mallModel.zone.id,
    //   status: selectedStatus?.toInt() ?? widget.mallModel.status,
    // );
  }
}

// Updated function to show the dialog
void showEditMallDialog(BuildContext context, MallModel mallModel) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return editMallsAlertDialog(mallModel: mallModel);
    },
  );
}

// Time formatting function (keeping your existing one)
String formatingTime(String timeFromJson) {
  try {
    if (timeFromJson.isEmpty) {
      return 'Not specified';
    }

    String fixedTime = timeFromJson.replaceAll('.', ':');
    DateFormat inputFormat = DateFormat("H:mm:ss");
    DateTime time = inputFormat.parse(fixedTime);
    DateFormat outputFormat = DateFormat("h:mm a");
    String formattedTime = outputFormat.format(time);
    return formattedTime;
  } catch (e) {
    print("Error formatting time: $timeFromJson, Error: $e");
    return timeFromJson;
  }
}
