import 'package:flutter/material.dart';

// Helper function to show messages using custom overlay toast
void showCustomToast(BuildContext context, String message,
    {bool isError = false}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 80.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isError ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: isError ? 14.0 : 16.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: isError ? 4 : 2), () {
    overlayEntry.remove();
  });
}

// Helper function for success messages
void showSuccessToast(BuildContext context, String message) {
  showCustomToast(context, message, isError: false);
}

// Helper function for error messages
void showErrorToast(BuildContext context, String message) {
  showCustomToast(context, message, isError: true);
}
