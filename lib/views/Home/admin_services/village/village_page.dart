import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Cubit/Village/village_cubit.dart';
import 'package:sa7el/views/Home/admin_services/village/widget/add_village.dart';
import 'package:sa7el/views/Home/admin_services/village/widget/filter_village.dart';
import 'package:sa7el/views/Home/admin_services/village/widget/village_list.dart';

class VillagePage extends StatelessWidget {
  const VillagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Adjust padding and sizes based on screen size
    double horizontalPadding = screenWidth * 0.04; // 4% of screen width
    double searchIconSize = screenWidth * 0.05; // 5% of screen width
    double buttonHeight = screenHeight * 0.07; // 7% of screen height
    double fontSize = screenWidth * 0.04; // 4% of screen width

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:  Text("Villages",style: TextStyle(color: WegoColors.mainColor,fontSize: 24,fontWeight: FontWeight.bold),),
        centerTitle: true,
        elevation: 0,

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
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              end: MediaQuery.of(context).size.width * 0.01,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: WegoColors.cardColor,
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddVillage()));
                },
                icon: Icon(
                  Icons.add,
                  color: WegoColors.mainColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      context.read<VillageCubit>().searchVillages(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: fontSize,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: WegoColors.mainColor,
                        size: searchIconSize,
                      ),
                      filled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                        borderSide: BorderSide(
                          color: WegoColors.mainColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding),
                Container(
                  decoration: BoxDecoration(
                    color: WegoColors.mainColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune,
                        color: Colors.white, size: searchIconSize),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FilterVillage()),
                      );
                    },
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: screenHeight * 0.02,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Village List
          Expanded(
            child: VillageList(),
          ),
        ],
      ),
    );
  }
}