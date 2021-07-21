import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
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

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 60,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(SizeConfig.basePadding),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2.0,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: selected != null
                ? Text(
                    DateFormat.yMMMMd().format(selected!),
                    style: Theme.of(context).textTheme.subtitle1,
                  )
                : Text(
                    'Tag Monat Jahr',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
          ),
        ),
        if (widget.enabled)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SizeConfig.basePadding,
            ),
            width: 100,
            child: CMTextButton(
              child: Icon(
                LineIcons.edit,
                size: 35,
              ),
              onPressed: () async {
                final DateTime? time = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(
                    Duration(days: 360),
                  ),
                  lastDate: DateTime.now().add(
                    Duration(days: 360),
                  ),
                );
                if (time != null) {
                  setState(() {
                    widget.onSaved(time);
                    selected = time;
                  });
                }
              },
            ),
          ),
      ],
    );
  }
}
