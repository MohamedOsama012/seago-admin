import 'package:flutter/material.dart';
import 'package:sa7el/Core/toast_helper.dart';

void customSnackBar({
  required BuildContext context,
  required String message,
  bool isError = true,
}) {
  showCustomToast(context, message, isError: isError);
}
