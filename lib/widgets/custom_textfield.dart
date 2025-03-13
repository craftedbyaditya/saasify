import 'package:flutter/material.dart';
import 'package:saasify_lite/constants/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? suffixIconData;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final InputDecoration? decoration;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    this.label = '',
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.decoration,
    this.style,
    this.contentPadding,
    this.suffixIconData,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.paddingSmall),
          child: Text(label!),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: TextFormField(
            focusNode: focusNode,
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            minLines: minLines,
            enabled: enabled,
            style: style ?? Theme.of(context).textTheme.bodySmall,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            decoration:
                decoration ??
                InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  filled: true,

                  fillColor: Colors.white,
                  prefixIcon:
                      suffixIcon ??
                      (suffixIconData != null
                          ? IconButton(
                            icon: Icon(suffixIconData),
                            onPressed: () {},
                          )
                          : null),
                  contentPadding:
                      contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
          ),
        ),
      ],
    );
  }
}
