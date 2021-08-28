import 'package:campus_motorsport/models/component_containers/event.dart';
import 'package:campus_motorsport/utilities/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({
    required this.onSaved,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  final void Function(Event?) onSaved;
  final String currentUser;

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  String? name;
  String? description;
  int? decrementBy;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Event eintragen',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(
                height: SizeConfig.basePadding,
              ),
              Text(
                'Gib dem Event einen Namen und optional eine Beschreibung.\n\n'
                'Wichtig: Ein Event einzutragen kann Einfluss auf den Zustand des Fahrzeuges haben.\n'
                'Die Betriebsstunden-Zähler der Komponenten wird um den eingetragenen Wert verringert und der Status bei Erreichen von 0 verschlechtert.',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextField(
                label: 'Name',
                validate: (value) => Validators().validateNotEmpty(
                  value,
                  'Name',
                ),
                onSaved: (value) {
                  name = value;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextField(
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                label: 'Beschreibung',
                onSaved: (value) {
                  description = value;
                },
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextField(
                label: 'Betriebsstunden',
                textInputType: TextInputType.number,
                onSaved: (value) {
                  decrementBy = int.tryParse(value ?? '');
                },
                validate: (value) => Validators().validateIntValue(value, true),
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextButton(
                child: Text('SPEICHERN'),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    widget.onSaved(
                      Event(
                        decrementCounterBy: decrementBy!,
                        name: name!,
                        by: widget.currentUser,
                        date: DateTime.now(),
                        description: description,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
