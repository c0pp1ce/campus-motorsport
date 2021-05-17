import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validation_services.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

/// Code input field based on the pinput package.
class CodeInput extends StatelessWidget {
  static const codeLength = ValidationServices.invitationCodeLength;

  final void Function(String?) onSaved;
  final String? Function(String?) validate;
  final TextInputType? textInputType;
  final bool? enabled;
  final Color? fillColor;

  /// Workaround to get a different border if an error occurs.
  final bool? error;

  CodeInput({
    required this.onSaved,
    required this.validate,
    this.textInputType,
    this.enabled,
    this.fillColor,
    this.error,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PinPut(
      fieldsCount: codeLength,
      onSaved: onSaved,
      validator: validate,
      keyboardType: textInputType ?? TextInputType.number,
      enabled: enabled ?? true,
      inputDecoration: _inputDecoration(context),
      selectedFieldDecoration: _selectedDecoration(context),
      followingFieldDecoration: _followingDecoration(context),
      disabledDecoration: _disabledDecoration(context),
      submittedFieldDecoration: _submittedDecoration(context),
      keyboardAppearance: Theme.of(context).colorScheme.brightness,
      textCapitalization: TextCapitalization.characters,
      pinAnimationType: PinAnimationType.none,
      textInputAction: TextInputAction.done,
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      hintStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
            fontSize: 12,
            color: Theme.of(context).colorScheme.error,
          ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: fillColor != null ? true : false,
      fillColor: fillColor,
      counterText: '',
      border: InputBorder.none,
    );
  }

  BoxDecoration _selectedDecoration(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primary;
    if(error ?? false) color = Theme.of(context).colorScheme.error;
    return BoxDecoration(
      color: color.withOpacity(0.2),
      border: Border.all(
        color: color,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(20.0),
    );
  }

  BoxDecoration _followingDecoration(BuildContext context) {
    Color color = Theme.of(context).colorScheme.secondary;
    if(error ?? false) color = Theme.of(context).colorScheme.error;
    return BoxDecoration(
      border: Border.all(
        color: ColorServices.darken(color, 60),
      ),
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  BoxDecoration _submittedDecoration(BuildContext context) {
    Color color = Theme.of(context).colorScheme.primaryVariant;
    if(error ?? false) color = ColorServices.darken(Theme.of(context).colorScheme.error, 10);
    return BoxDecoration(
      border: Border.all(
        color: color,
      ),
      borderRadius: BorderRadius.circular(10.0),
    );
  }

  BoxDecoration _disabledDecoration(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.surface;
    return BoxDecoration(
      color: color.withOpacity(0.4),
      border: Border.all(
        color: color,
      ),
      borderRadius: BorderRadius.circular(10.0),
    );
  }
}
