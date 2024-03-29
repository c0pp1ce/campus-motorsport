import 'package:flutter/material.dart';

import 'package:campus_motorsport/utilities/color_services.dart';

/// Styled [TextFormField] to be used throughout the app.
class CMTextField extends StatefulWidget {
  const CMTextField({
    this.hint,
    this.label,
    this.initialValue,
    this.validate,
    this.onSaved,
    this.onChanged,
    this.textInputType,
    this.textInputAction,
    this.toggleObscure = false,
    this.enabled = true,
    this.fillColor,
    this.minLines = 1,
    this.maxLines = 1,
    this.controller,
    this.noBorders = false,
    this.style,
    Key? key,
  }) : super(key: key);

  final String? hint;
  final String? label;
  final String? initialValue;

  final String? Function(String?)? validate;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;

  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final Color? fillColor;

  /// If set to true, a suffix icon will be displayed which toggles obscureText.
  final bool toggleObscure;
  final bool enabled;

  final int minLines;
  final int maxLines;
  final bool noBorders;

  final TextStyle? style;

  final TextEditingController? controller;

  @override
  _CMTextFieldState createState() => _CMTextFieldState();
}

class _CMTextFieldState extends State<CMTextField> {
  /// Used to switch label color when field is focused.
  FocusNode? _focusNode;

  /// Used to switch label color when an error occurred and field is focused.
  bool _errorShown = false;

  /// Used for password input.
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscure = widget.toggleObscure;

    /// Update state of the focus node.
    _focusNode!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: widget.style,
      controller: widget.controller,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      validator: _validate,
      textInputAction: widget.textInputAction,
      keyboardType: widget.textInputType,
      decoration: _style(context, widget.hint, widget.label),
      cursorColor: Theme.of(context).colorScheme.secondary,
      obscureText: _obscure,
      keyboardAppearance: Theme.of(context).colorScheme.brightness,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
    );
  }

  /// Wrapper for the validation method to set error state according to validation
  /// result.
  String? _validate(String? value) {
    if (widget.validate != null) {
      final String? result = widget.validate!(value);
      if (result != null) {
        setState(() {
          _errorShown = true;
        });
        return result;
      } else {
        setState(() {
          _errorShown = false;
        });
      }
    }
  }

  /// Defines the style of the text field.
  InputDecoration _style(BuildContext context, String? hint, String? label) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
      labelText: label,
      labelStyle: _labelStyle(context),
      errorStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
            fontSize: 12,
            color: Theme.of(context).colorScheme.error,
          ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: widget.fillColor != null,
      fillColor: widget.fillColor,
      enabledBorder:
          widget.noBorders ? InputBorder.none : _enabledBorder(context),
      disabledBorder:
          widget.noBorders ? InputBorder.none : _disabledBorder(context),
      errorBorder: widget.noBorders ? InputBorder.none : _errorBorder(context),
      focusedBorder:
          widget.noBorders ? InputBorder.none : _focusedBorder(context),
      focusedErrorBorder:
          widget.noBorders ? InputBorder.none : _focusedErrorBorder(context),

      /// Only show eye-icon when toggleObscure is set to true.
      suffixIcon: !widget.toggleObscure ? null : _switchObscure(context),
    );
  }

  /// Label color changes based on focus and error state.
  TextStyle? _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.subtitle1?.copyWith(
          color: _focusNode!.hasFocus
              ? _errorShown
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        );
  }

  GestureDetector _switchObscure(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _obscure = !_obscure;
        });
      },
      child: Icon(
        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: _focusNode!.hasFocus
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }

  /// Style of the border, if the text field is enabled but not focused.
  InputBorder _enabledBorder(BuildContext context) {
    return OutlineInputBorder(
      gapPadding: 3.0,
      borderSide: BorderSide(
        color:
            ColorServices.brighten(Theme.of(context).colorScheme.surface, 40),
        width: 1.0,
        style: BorderStyle.solid,
      ),
    );
  }

  /// Style of the border, if the text field is disabled.
  InputBorder _disabledBorder(BuildContext context) {
    return OutlineInputBorder(
      gapPadding: 3.0,
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.surface,
        width: 2.0,
        style: BorderStyle.solid,
      ),
    );
  }

  /// Style of the border, if an error occurred and the field is not focused.
  InputBorder _errorBorder(BuildContext context) {
    return OutlineInputBorder(
      gapPadding: 3.0,
      borderSide: BorderSide(
        color: ColorServices.darken(Theme.of(context).colorScheme.error, 60),
        width: 1.0,
        style: BorderStyle.solid,
      ),
    );
  }

  /// Style of the border, if the text field is focused.
  InputBorder _focusedBorder(BuildContext context) {
    return OutlineInputBorder(
      gapPadding: 3.0,
      borderSide: BorderSide(
        color:
            ColorServices.brighten(Theme.of(context).colorScheme.surface, 80),
        width: 1.3,
        style: BorderStyle.solid,
      ),
    );
  }

  /// Style of the border, if the text field is focused and an error occurred.
  InputBorder _focusedErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      gapPadding: 3.0,
      borderSide: BorderSide(
        color: ColorServices.darken(Theme.of(context).colorScheme.error, 10),
        width: 1.0,
        style: BorderStyle.solid,
      ),
    );
  }
}
