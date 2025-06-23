import 'package:flutter/material.dart';
import 'package:sa7el/Core/images_url.dart';

class CustomActionsCard extends StatelessWidget {
  const CustomActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 202,
      width: 164,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Image.network(WegoImages.mallIcon)],
        ),
      ),
    );
  }
}
