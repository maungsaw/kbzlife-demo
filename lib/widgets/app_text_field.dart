import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import 'app_text.dart';

class AppTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool showFlag;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final String? helperText;
  final String? errorText;
  final Widget? child;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.showFlag = false,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.contentPadding,
    this.helperText,
    this.errorText,
    this.child,
  });

  @override
  ConsumerState<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends ConsumerState<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A field wrapped by something that already prints the label (the
        // quote renderer does) passes an empty one — it must not leave a
        // blank line behind.
        if (widget.label.isNotEmpty) ...[
          AppLabelText(widget.label),
          const SizedBox(height: 6),
        ],
        if (widget.child != null)
          InputDecorator(
            decoration: _inputDecoration(),
            child: InkWell(onTap: widget.onTap, child: widget.child),
          )
        else
          TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword ? widget.obscureText : false,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            initialValue: widget.initialValue,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            onChanged: widget.onChanged,
            inputFormatters: widget.inputFormatters,
            onTap: widget.onTap,
            style: TextStyle(
              fontSize: AppType.body,
              color: context.colors.textPrimary,
            ),
            validator: widget.validator,
            decoration: _inputDecoration(),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      prefixIcon: widget.prefixIcon ?? _buildPrefixIcon(),
      suffixIcon: widget.suffixIcon ?? _buildSuffixIcon(),
      suffixText: (widget.suffixIcon == null && widget.isPassword == false)
          ? widget.suffixText
          : null,
      // The unit reads as a unit, not as part of the value: same size as
      // the text it follows, in the secondary ink.
      suffixStyle: TextStyle(
        fontSize: AppType.body,
        fontWeight: AppType.normal,
        color: context.colors.textSecondary,
      ),
      hintText: widget.hint,
      helperText: widget.helperText,
      helperMaxLines: 2,
      errorText: widget.errorText,
      hintStyle: TextStyle(
        fontSize: AppType.body,
        color: context.colors.textSecondary,
      ),
      contentPadding:
          widget.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: widget.enabled ? Colors.white : context.colors.surfaceBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.colors.danger),
      ),
    );
  }

  Widget? _buildPrefixIcon() {
    if (widget.showFlag) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇲🇲', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              '+95',
              style: TextStyle(
                fontSize: AppType.body,
                fontWeight: AppType.strong,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(height: 20, width: 1, color: context.colors.border),
          ],
        ),
      );
    }
    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          widget.obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: context.iconLg,
          color: context.colors.muted,
        ),
        onPressed: widget.onToggleVisibility,
      );
    }
    return null;
  }
}
