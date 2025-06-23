import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';

Widget customAdminMallCardDetails(
  BuildContext context,
  int index, {
  required bool isGrid,
  required String title,
  required String info,
  required dynamic mall, // Your mall object
  required VoidCallback edit,
  required String infoDesc,
  required String openFrom,
  required VoidCallback delete,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth >= 768;
  final isDesktop = screenWidth >= 1024;

  // Responsive font sizes
  final titleFontSize = isDesktop ? 20.0 : (isTablet ? 18.0 : 16.0);
  final detailFontSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
  final buttonFontSize = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

  // Responsive padding
  final cardPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);

  return Container(
    margin: const EdgeInsets.only(bottom: 16.0),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title

        SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            if (mall.status == 1)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Active",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (mall.status == 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Inactive",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        // Description/Info
        Text(
          info,
          style: TextStyle(
            fontSize: detailFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.teal.shade700,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),

        // Description/Info
        Text(
          openFrom,
          style: TextStyle(
            fontSize: detailFontSize,
            fontWeight: FontWeight.w400,
            color: Colors.teal.shade700,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isDesktop ? 12 : (isTablet ? 10 : 8)),

        // Description/Info

        SizedBox(height: isDesktop ? 20 : (isTablet ? 16 : 12)),

        // Action Buttons
        _buildActionButtons(
          context,
          buttonFontSize,
          isDesktop,
          isTablet,
          edit,
          delete,
        ),
      ],
    ),
  );
}

Widget _buildActionButtons(
  BuildContext context,
  double fontSize,
  bool isDesktop,
  bool isTablet,
  VoidCallback edit,
  VoidCallback delete,
) {
  final buttonPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);
  final buttonSpacing = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            onPressed: edit,
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
          height: 45,
          child: OutlinedButton(
            onPressed: delete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.teal,
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
