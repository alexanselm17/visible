import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String label;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final double borderRadius;
  final double contentPadding;
  final Widget? suffixIcon;
  final bool? enabled;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    required this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    required this.borderRadius,
    required this.contentPadding,
    this.suffixIcon,
    required this.label,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          onEditingComplete: onEditingComplete,
          validator: validator,
          decoration: InputDecoration(
            hintText: labelText,
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            contentPadding: EdgeInsets.all(contentPadding),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
