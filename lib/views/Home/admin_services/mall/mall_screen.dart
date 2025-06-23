import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/images_url.dart';
import 'package:sa7el/Core/text_styles.dart';
import 'package:sa7el/Cubit/malls/malls_cubit.dart';
import 'package:sa7el/Cubit/malls/malls_states.dart';
import 'package:sa7el/Model/malls_model.dart';
import 'package:sa7el/controller/cashe/cashe_Helper.dart';
import 'package:sa7el/views/Authentication/widgets/custom_snackBar.dart';
import 'package:sa7el/views/Home/Widgets/custom_appBar.dart';
import 'package:sa7el/views/Home/Widgets/custom_details_for_card.dart';
import 'package:sa7el/views/Home/admin_services/mall/add_mall_screen.dart';
import 'package:sa7el/views/Home/admin_services/mall/edit_malls_alertDialog.dart';
import 'package:sa7el/views/Home/admin_services/mall/mall_filters_screen.dart';
import 'package:sa7el/views/Home/admin_services/village/widget/filter_village.dart';

class MallServicesUIPage extends StatefulWidget {
  const MallServicesUIPage({super.key});

  @override
  State<MallServicesUIPage> createState() => _MallServicesUIPageState();
}

class _MallServicesUIPageState extends State<MallServicesUIPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize search functionality
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
      // Call search function from cubit
      final cubit = MallsCubit.get(context);
      cubit.searchMalls(_searchQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.width;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Adjust padding and sizes based on screen size
    double horizontalPadding = screenWidth * 0.04; // 4% of screen width
    double searchIconSize = screenWidth * 0.05; // 5% of screen width
    double buttonHeight = screenHeight * 0.07; // 7% of screen height
    double fontSize = screenWidth * 0.04;

    return BlocConsumer<MallsCubit, MallsStates>(
      listener: (BuildContext context, MallsStates state) {
        if (state is MallsGetDataErrorState) {
          customSnackBar(context: context, message: state.error);
        }
      },
      builder: (BuildContext context, MallsStates state) {
        final cubit = MallsCubit.get(context);

        // Determine which list to show based on search query
        List<MallModel> mallsToShow =
            _searchQuery.isEmpty ? cubit.items : cubit.filteredMalls;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "Malls",
              style: TextStyle(
                  color: WegoColors.mainColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
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
                    onPressed: () async {
                      // استخدم await عشان تستنى النتيجة
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMallPage()));

                      // لو رجع true يعني المول اتضاف بنجاح
                      if (result == true) {
                        // تحديث البيانات من السيرفر
                        MallsCubit.get(context).getData();

                        // اختياري: عرض رسالة تأكيد إضافية
                        customSnackBar(
                            context: context,
                            message: "Mall list updated successfully");
                      }
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
              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search malls...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: fontSize,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: WegoColors.mainColor,
                            size: searchIconSize,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                    size: searchIconSize,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    cubit.searchMalls('');
                                  },
                                )
                              : null,
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.06),
                            borderSide: BorderSide(
                              color: WegoColors.mainColor,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.06),
                            borderSide: BorderSide(
                              color: WegoColors.mainColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.06),
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
                                builder: (context) => FilterMalls()),
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

              // Results count (optional)
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Found ${mallsToShow.length} mall${mallsToShow.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: fontSize * 0.9,
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading state
              if (state is MallsGetDataLoadingState)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: WegoColors.mainColor,
                    ),
                  ),
                ),

              // Mall List
              if (state is! MallsGetDataLoadingState)
                Expanded(
                  child: mallsToShow.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty
                                    ? Icons.store
                                    : Icons.search_off,
                                size: screenWidth * 0.2,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No malls available'
                                    : 'No malls found for "$_searchQuery"',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: fontSize,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    cubit.searchMalls('');
                                  },
                                  child: Text('Clear search'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: mallsToShow.length,
                          itemBuilder: (context, index) {
                            final mall = mallsToShow[index];
                            String openFrom = formatingTime(mall.openFrom);
                            String openTo = formatingTime(mall.openTo);

                            return customAdminMallCardDetails(context, index,
                                isGrid: false,
                                title: mall.name,
                                info: "Zone: ${mall.zone.name}",
                                infoDesc: "Description: ${mall.description}",
                                openFrom: "Opening Time: $openFrom - $openTo",
                                mall: mall, edit: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      editMallsAlertDialog(mallModel: mall));
                            }, delete: () {
                              // Implement delete functionality here
                              _showDeleteConfirmation(context, mall, cubit);
                            });
                          },
                        ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, MallModel mall, MallsCubit cubit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocListener<MallsCubit, MallsStates>(
          listener: (context, state) {
            // TODO: implement listener
            if (state is MallsDeleteSuccessState) {
              Navigator.of(context).pop();
              customSnackBar(
                  context: context,
                  message: '${mall.name} deleted successfully');
            } else if (state is MallsDeleteFailedState) {
              Navigator.of(context).pop();
              customSnackBar(context: context, message: state.errMessage);
            }
          },
          child: AlertDialog(
            title: const Text('Delete Mall'),
            content: Text('Are you sure you want to delete ${mall.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              BlocBuilder<MallsCubit, MallsStates>(
                builder: (context, state) {
                  if (state is MallsDeleteLoadingState) {
                    return CircularProgressIndicator(
                        color: WegoColors.mainColor);
                  } else {
                    return TextButton(
                      onPressed: () {
                        // Implement your delete logic here
                        cubit.deleteData(mall.id);
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

String formatingTime(String timeFromJson) {
  try {
    // Handle null or empty time
    if (timeFromJson.isEmpty) {
      return 'Not specified';
    }

    // Step 1: Replace dots with colons
    String fixedTime = timeFromJson.replaceAll('.', ':');

    // Step 2: Parse the time string using DateFormat
    DateFormat inputFormat = DateFormat("H:mm:ss");
    DateTime time = inputFormat.parse(fixedTime);

    // Step 3: Format it to your desired output
    DateFormat outputFormat = DateFormat("h:mm a");
    String formattedTime = outputFormat.format(time);
    return formattedTime;
  } catch (e) {
    print("Error formatting time: $timeFromJson, Error: $e");
    return timeFromJson; // Return original string if formatting fails
  }
}
