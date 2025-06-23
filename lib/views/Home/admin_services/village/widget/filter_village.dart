import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/Cubit/Village/village_states.dart';

class FilterVillage extends StatefulWidget {
  const FilterVillage({super.key});

  @override
  State<FilterVillage> createState() => _FilterVillageState();
}

class _FilterVillageState extends State<FilterVillage> {
  num? selectedZoneId;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<VillageCubit>();
    if (cubit.zones.isEmpty) {
      cubit.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Filter Villages",
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
      body: BlocConsumer<VillageCubit, VillageStates>(
        listener: (context, state) {
          if (state is VillageErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = VillageCubit.get(context);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                if (state is VillaLoadingState && cubit.zones.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(
                      color: WegoColors.mainColor,
                    ),
                  )
                else
                  _buildZoneDropdown(cubit),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedZoneId = null;
                      });
                      cubit.filterVillagesByZone(null);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WegoColors.mainColor,
                      side: BorderSide(color: WegoColors.mainColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                    ),
                    child: const Text(
                      'Clear Filter',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.filterVillagesByZone(selectedZoneId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WegoColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                    ),
                    child: const Text(
                      'Apply Filter',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoneDropdown(VillageCubit cubit) {
    return DropdownButtonFormField<num?>(
      value: selectedZoneId,
      hint: const Text('Select Zone'),
      items: [
        const DropdownMenuItem<num?>(
          value: null,
          child: Text('All Zones'),
        ),
        ...cubit.zones.map((zone) {
          return DropdownMenuItem<num?>(
            value: zone.id,
            child: Text(zone.name ?? 'Unnamed Zone'),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          selectedZoneId = value;
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
