import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

class CMDatePicker extends StatefulWidget {
  const CMDatePicker({
    required this.onSaved,
    this.enabled = true,
    this.initialValue,
    Key? key,
  }) : super(key: key);

  final DateTime? initialValue;
  final void Function(DateTime) onSaved;
  final bool enabled;

  @override
  _CMDatePickerState createState() => _CMDatePickerState();
}

class _CMDatePickerState extends State<CMDatePicker> {
  DateTime? selected;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: AbsorbPointer(
            child: CMTextField(
              maxLines: 1,
              minLines: 1,
              controller: _textEditingController,
              enabled: widget.enabled,
              validate: (value) =>
                  Validators().validateNotEmpty(value, 'Datum'),
            ),
          ),
        ),
        if (widget.enabled)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SizeConfig.basePadding,
            ).add(
              /// Centers the button next to the TextField even when a validation
              /// error is shown.
              EdgeInsets.only(top: 7),
            ),
            width: 100,
            child: CMTextButton(
              child: Icon(
                LineIcons.edit,
                size: 35,
              ),
              onPressed: () async {
                final DateTime? time = await showDatePicker(
                  helpText: 'Datum wählen',
                  cancelText: 'ABBRECHEN',
                  context: context,
                  initialDate: DateTime.now(),
                  currentDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(
                    Duration(days: 360),
                  ),
                  lastDate: DateTime.now().add(
                    Duration(days: 360),
                  ),
                );
                if (time != null) {
                  setState(() {
                    widget.onSaved(time.toUtc());
                    selected = time.toUtc();
                    _textEditingController.text =
                        DateFormat.yMMMMd().format(selected!);
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}
