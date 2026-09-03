import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../const.dart';

class AppsTextField extends ConsumerStatefulWidget {
  const AppsTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.style,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.textInputAction,
    this.contentPadding,
    this.counterText,
  }) : assert(
         controller == null || initialValue == null,
         'Cannot supply both a controller and an initialValue',
       );

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// Leading icon — pass the semantically appropriate [IconData] (e.g.
  /// `Icons.lock_outline`, `Icons.phone_iphone`, `Icons.person_outline`).
  final IconData? prefixIcon;

  /// Custom trailing icon. Ignored when [showObscureToggle] is true (the
  /// built-in show/hide toggle takes over the suffix slot).
  final Widget? suffixIcon;

  /// Inline trailing text (e.g. a unit like "MMK" or "%"). Ignored when
  /// [showObscureToggle] or [suffixIcon] is set.
  final String? suffixText;

  final bool obscureText;

  /// When true and [obscureText] starts true, renders a built-in
  /// show/hide suffix icon for password fields.
  final bool showObscureToggle;

  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final TextStyle? style;
  final int? maxLines;
  final int? maxLength;

  /// Keystroke-level input rules (e.g. a running budget cap).
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final String? counterText;

  @override
  ConsumerState<AppsTextField> createState() => _AppsTextFieldState();
}

class _AppsTextFieldState extends ConsumerState<AppsTextField> {
  late bool _obscured = widget.obscureText;

  @override
  void didUpdateWidget(covariant AppsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText)
      // ignore: curly_braces_in_flow_control_structures
      _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSuffix = widget.showObscureToggle
        ? IconButton(
            icon: Icon(
              _obscured
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: context.iconLg,
            ),
            onPressed: () => setState(() => _obscured = !_obscured),
          )
        : widget.suffixIcon;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      style: widget.style,
      maxLines: _obscured ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        errorText: widget.errorText,
        counterText: widget.counterText,
        contentPadding: widget.contentPadding,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: context.iconLg)
            : null,
        suffixIcon: effectiveSuffix,
        suffixText: effectiveSuffix == null ? widget.suffixText : null,
      ),
    );
  }
}
