import 'package:flutter/material.dart';
import 'package:sa7el/Core/colors.dart';
import 'package:sa7el/Core/text_styles.dart';

class CustomHeaderDetailsCard extends StatelessWidget {
  const CustomHeaderDetailsCard({
    super.key,
    required this.numberTextCard,
    required this.detailsTitleTextCard,
    required this.detailssubTitleTextCard,
  });
  final int? numberTextCard;
  final String? detailsTitleTextCard;
  final String? detailssubTitleTextCard;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Container(
      width: 162,
      height: 83,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            top: height * 0.011,
            left: width * 0.03,
            child: Row(
              children: [
                Text(
                  "$numberTextCard ",
                  style: WegoTextStyles.smallCardNumbersTextStyle,
                ),

                Text(
                  "$detailsTitleTextCard",
                  style: WegoTextStyles.meduimCardTextStyle,
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.055,
            left: width * 0.05,
            child: Text(
              "$detailssubTitleTextCard",
              style: WegoTextStyles.smallestCardNumbersTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
