import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visible/constants/colors.dart';

/// Base reusable text form field with consistent styling and animations
class BaseFormField extends StatelessWidget {
  final String label;
  final String? helperText;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final bool isValid;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final Duration animationDelay;
  final bool animate;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showBorder;
  final String? errorText;
  final EdgeInsetsGeometry contentPadding;

  const BaseFormField({
    super.key,
    required this.label,
    this.helperText,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.isValid = true,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines = 1,
    this.animationDelay = Duration.zero,
    this.animate = true,
    this.focusNode,
    this.autofocus = false,
    this.showBorder = true,
    this.errorText,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final fieldWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: showBorder
                ? Border.all(
                    color: !isValid ? Colors.red : Colors.grey.shade300,
                    width: 1,
                  )
                : null,
            boxShadow: showBorder
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            obscureText: obscureText,
            readOnly: readOnly,
            enabled: enabled,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: contentPadding,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              errorText: errorText,
            ),
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            validator: validator,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            minLines: minLines,
          ),
        ),

        // Helper text if provided
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );

    // Apply animation conditionally
    if (animate) {
      return fieldWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms)
          .slideX(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
    }

    return fieldWidget;
  }
}

/// Standard form field for most common use cases
class StandardFormField extends StatelessWidget {
  final String label;
  final String? helperText;
  final TextEditingController? controller;
  final String? hintText;
  final IconData prefixIconData;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final bool isValid;
  final List<TextInputFormatter>? inputFormatters;
  final Duration animationDelay;
  final bool animate;
  final Color? prefixIconColor;

  const StandardFormField({
    super.key,
    required this.label,
    this.helperText,
    this.controller,
    this.hintText,
    required this.prefixIconData,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.isValid = true,
    this.inputFormatters,
    this.animationDelay = Duration.zero,
    this.animate = true,
    this.prefixIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return BaseFormField(
      label: label,
      helperText: helperText,
      controller: controller,
      hintText: hintText,
      prefixIcon: Icon(prefixIconData, color: prefixIconColor ?? Colors.grey),
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      enabled: enabled,
      isValid: isValid,
      inputFormatters: inputFormatters,
      animationDelay: animationDelay,
      animate: animate,
    );
  }
}

/// Password form field with toggle visibility
class PasswordFormField extends StatefulWidget {
  final String label;
  final String? helperText;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool isValid;
  final Duration animationDelay;
  final bool animate;
  final bool isConfirmPassword;

  const PasswordFormField({
    super.key,
    required this.label,
    this.helperText,
    this.controller,
    this.hintText,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.isValid = true,
    this.animationDelay = Duration.zero,
    this.animate = true,
    this.isConfirmPassword = false,
  });

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BaseFormField(
      label: widget.label,
      helperText: widget.helperText,
      controller: widget.controller,
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      validator: widget.validator,
      onChanged: widget.onChanged,
      isValid: widget.isValid,
      animationDelay: widget.animationDelay,
      animate: widget.animate,
    );
  }
}

/// Phone form field specifically for Kenyan phone numbers
class KenyaPhoneFormField extends StatelessWidget {
  final String label;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final bool isValid;
  final Duration animationDelay;
  final bool animate;

  const KenyaPhoneFormField({
    super.key,
    required this.label,
    this.helperText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.isValid = true,
    this.animationDelay = Duration.zero,
    this.animate = true,
  });

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Additional validation can be added here
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormField(
      label: label,
      helperText: helperText,
      controller: controller,
      hintText: "7XX XXX XXX",
      prefixIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/Flag_of_Kenya.png',
              width: 24,
              height: 16,
            ),
            const SizedBox(width: 8),
            const Text(
              "+254",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validator ?? _validatePhone,
      onChanged: onChanged,
      enabled: enabled,
      isValid: isValid,
      animationDelay: animationDelay,
      animate: animate,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
        // Custom formatter to add spaces
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          if (text.length <= 3) return newValue;

          String newText = text.replaceAll(' ', '');
          final buffer = StringBuffer();

          for (int i = 0; i < newText.length; i++) {
            if (i == 3 || i == 6) {
              buffer.write(' ');
            }
            buffer.write(newText[i]);
          }

          return TextEditingValue(
            text: buffer.toString(),
            selection: TextSelection.collapsed(offset: buffer.length),
          );
        }),
      ],
    );
  }
}

/// Selection chip for multiple-choice options (like gender, occupation)
class SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? iconData;

  const SelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.accentOrange : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Binary selection field (e.g., gender)
class BinarySelectionField extends StatelessWidget {
  final String label;
  final String option1;
  final String option2;
  final IconData? icon1;
  final IconData? icon2;
  final String? selectedValue;
  final Function(String) onChanged;
  final Duration animationDelay;
  final bool animate;

  const BinarySelectionField({
    super.key,
    required this.label,
    required this.option1,
    required this.option2,
    this.icon1,
    this.icon2,
    required this.selectedValue,
    required this.onChanged,
    this.animationDelay = Duration.zero,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectionWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SelectionChip(
                label: option1,
                iconData: icon1,
                isSelected: selectedValue == option1,
                onTap: () => onChanged(option1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SelectionChip(
                label: option2,
                iconData: icon2,
                isSelected: selectedValue == option2,
                onTap: () => onChanged(option2),
              ),
            ),
          ],
        ),
      ],
    );

    if (animate) {
      return selectionWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms)
          .slideY(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
    }

    return selectionWidget;
  }
}

/// Multiple selection field (e.g., occupation)
class MultipleSelectionField extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final Function(String) onChanged;
  final Duration animationDelay;
  final bool animate;

  const MultipleSelectionField({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.animationDelay = Duration.zero,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final fieldWidget = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options
                .map((option) => SelectionChip(
                      label: option,
                      isSelected: selectedValue == option,
                      onTap: () => onChanged(option),
                    ))
                .toList(),
          ),
        ],
      ),
    );

    if (animate) {
      return fieldWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms)
          .slideY(
              begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutQuad);
    }

    return fieldWidget;
  }
}

/// Terms and conditions checkbox with rich text
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final Duration animationDelay;
  final bool animate;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
    this.animationDelay = Duration.zero,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final termsWidget = Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: value,
              activeColor: AppColors.accentOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                      text: 'By creating an account, I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (animate) {
      return termsWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms)
          .moveY(begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut);
    }

    return termsWidget;
  }
}

/// Action button for forms
class FormActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final Duration animationDelay;
  final bool animate;
  final bool isLoading;

  const FormActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.animationDelay = Duration.zero,
    this.animate = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: AppColors.pureWhite,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )
          : TextButton(
              onPressed: isLoading ? null : onPressed,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade700,
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
    );

    if (animate) {
      return buttonWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms);
    }

    return buttonWidget;
  }
}

/// Container for form navigation buttons (back/next)
class FormNavButtons extends StatelessWidget {
  final String primaryText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;
  final Duration animationDelay;
  final bool animate;
  final bool isLoading;

  const FormNavButtons({
    super.key,
    required this.primaryText,
    required this.onPrimaryPressed,
    this.secondaryText,
    this.onSecondaryPressed,
    this.animationDelay = Duration.zero,
    this.animate = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonsWidget = Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: secondaryText != null && onSecondaryPressed != null
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: FormActionButton(
                    text: secondaryText!,
                    onPressed: onSecondaryPressed!,
                    isPrimary: false,
                    animate: false,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FormActionButton(
                    text: primaryText,
                    onPressed: onPrimaryPressed,
                    isPrimary: true,
                    animate: false,
                    isLoading: isLoading,
                  ),
                ),
              ],
            )
          : FormActionButton(
              text: primaryText,
              onPressed: onPrimaryPressed,
              isPrimary: true,
              animate: false,
              isLoading: isLoading,
            ),
    );

    if (animate) {
      return buttonsWidget
          .animate(delay: animationDelay)
          .fadeIn(duration: 400.ms);
    }

    return buttonsWidget;
  }
}

/// Link text for navigation between auth screens
class AuthLinkText extends StatelessWidget {
  final String leadText;
  final String linkText;
  final VoidCallback onTap;
  final Duration animationDelay;
  final bool animate;

  const AuthLinkText({
    super.key,
    required this.leadText,
    required this.linkText,
    required this.onTap,
    this.animationDelay = Duration.zero,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final linkWidget = Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
            children: [
              TextSpan(text: '$leadText '),
              TextSpan(
                text: linkText,
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()..onTap = onTap,
              ),
            ],
          ),
        ),
      ),
    );

    if (animate) {
      return linkWidget.animate(delay: animationDelay).fadeIn(duration: 400.ms);
    }

    return linkWidget;
  }
}
