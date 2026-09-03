import 'package:flutter/material.dart';

import '../widgets/app_text_field.dart';

// Re-export for backward compatibility
export '../widgets/app_text_field.dart';

Widget buildInputField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool showFlag = false,
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? onToggleVisibility,
  String? Function(String?)? validator,
}) {
  return AppTextField(
    controller: controller,
    label: label,
    hint: hint,
    keyboardType: keyboardType,
    showFlag: showFlag,
    isPassword: isPassword,
    obscureText: obscureText,
    onToggleVisibility: onToggleVisibility,
    validator: validator,
  );
}
