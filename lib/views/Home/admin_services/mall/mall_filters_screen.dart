import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/views/Home/Widgets/custom_appBar.dart';

class FilterMalls extends StatefulWidget {
  const FilterMalls({super.key});

  @override
  State<FilterMalls> createState() => _FilterVillageState();
}

class _FilterVillageState extends State<FilterMalls> {
  String? selectedZone;

  final List<String> zones = [
    'Zone 1',
    'Zone 2',
    'Zone 3',
    'Zone 4',
  ];
  final List<String> malls = [
    'Mall 1',
    'Mall 2',
    'Mall 3',
    'Mall 4',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(
        title: "Filter Malls",
        context: context,
        onPressedAddIcon: () {},
        onPressedBackIcon: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // DropDown for Zone
            _buildDropdown(options: malls, title: "Select Mall"),
            SizedBox(height: 10),
            _buildDropdown(options: zones, title: "Select Zone"),

            const SizedBox(height: 30),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: استخدم selectedZone هنا
                  print('Selected zone: $selectedZone');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WegoColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      {required List<String> options, required String title}) {
    return DropdownButtonFormField<String>(
      value: selectedZone,
      hint: Text(title),
      items: options.map((zone) {
        return DropdownMenuItem(
          value: zone,
          child: Text(zone),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedZone = value;
        });
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: WegoColors.mainColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: WegoColors.mainColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
  }
}
