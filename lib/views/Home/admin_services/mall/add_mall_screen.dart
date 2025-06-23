import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';

class AddMallPage extends StatefulWidget {
  const AddMallPage({Key? key}) : super(key: key);

  @override
  State<AddMallPage> createState() => _AddMallPageState();
}

class _AddMallPageState extends State<AddMallPage> {
  final TextEditingController _mallNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _openingFromController = TextEditingController();
  final TextEditingController _openingToController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  int? _selectedZoneId;
  int _selectedStatus = 1; // Default to active

  @override
  void initState() {
    super.initState();
    // Load zones when screen opens
    context.read<VillageCubit>().getData();
  }

  @override
  void dispose() {
    _mallNameController.dispose();
    _locationController.dispose();
    _openingFromController.dispose();
    _openingToController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  String? _validateTime(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    // Simple time validation (you can make this more sophisticated)
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value.trim())) {
      return 'Please enter valid time format (HH:MM)';
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
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: WegoColors.mainColor, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: WegoColors.mainColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            filled: true,
            fillColor: Colors.white,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
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
          Row(
            children: [
              Text(
                _selectedStatus == 1 ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 14,
                  color: _selectedStatus == 1
                      ? WegoColors.mainColor
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Switch(
                value: _selectedStatus == 1,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ? 1 : 0;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: WegoColors.mainColor,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveMall() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = MallsCubit.get(context);

    // Find zone name from selected zone id
    final villageCubit = VillageCubit.get(context);
    final selectedZone = villageCubit.zones.firstWhere(
      (zone) => zone.id?.toInt() == _selectedZoneId,
      orElse: () => villageCubit.zones.first,
    );

    cubit.addMall(
      name: _mallNameController.text.trim(),
      status: _selectedStatus,
      zoneName: selectedZone.name ?? _locationController.text.trim(),
      openFrom: _openingFromController.text.trim(),
      openTo: _openingToController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Add Mall",
          style: TextStyle(
            color: WegoColors.mainColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
      body: BlocListener<MallsCubit, MallsStates>(
        listener: (context, state) {
          if (state is MallsAddLoadingState) {
            // Show loading
          } else if (state is MallsAddSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mall added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is MallsAddFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errMessage}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
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

                  // Mall Name Field
                  const Text(
                    'Mall Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Enter mall name',
                    WegoColors.mainColor,
                    controller: _mallNameController,
                    validator: (value) => _validateField(value, 'mall name'),
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

                  // Location Field (Optional since we have zone)
                  const Text(
                    'Specific Location (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Enter specific location details',
                    WegoColors.mainColor,
                    controller: _locationController,
                    validator: null, // Optional field
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  const Text(
                    'Description (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    'Enter mall description',
                    WegoColors.mainColor,
                    controller: _descriptionController,
                    validator: null, // Optional field
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // Opening Hours Section
                  const Text(
                    'Opening Hours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _buildTextField(
                              'HH:MM (e.g., 09:00)',
                              WegoColors.mainColor,
                              controller: _openingFromController,
                              validator: (value) =>
                                  _validateTime(value, 'opening time'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _buildTextField(
                              'HH:MM (e.g., 22:00)',
                              WegoColors.mainColor,
                              controller: _openingToController,
                              validator: (value) =>
                                  _validateTime(value, 'closing time'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Status Switch
                  _buildStatusSwitch(),
                  const SizedBox(height: 30),

                  // Save Button
                  BlocBuilder<MallsCubit, MallsStates>(
                    builder: (context, state) {
                      bool isLoading = state is MallsAddLoadingState;

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveMall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WegoColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
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
                                  'Save Mall',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
