import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';

AppBar appBar({
  required String title,
  required BuildContext context,
  Function? onPressedIcon,
  bool showAddButton = true,
  VoidCallback? onAddPressed,
  VoidCallback? onPressedBackIcon,
  VoidCallback? onPressedAddIcon,
}) {
  return AppBar(
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    elevation: 0,
    actions: [
      if (showAddButton)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WegoColors.cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: onAddPressed ?? () {},
              icon: Icon(
                Icons.add,
                size: 25,
                color: WegoColors.mainColor,
              ),
            ),
          ),
        ),
    ],
    leading: Padding(
      padding: EdgeInsetsDirectional.only(
        start: MediaQuery.of(context).size.width * 0.01,
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: WegoColors.cardColor,
        child: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: WegoColors.mainColor,
            size: 20,
          ),
        ),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: WegoColors.mainColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
    centerTitle: true,
  );
}
