import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';

/// A simple widget which is used in the process of adding new data fields to
/// a component.
class CreateDataInput extends StatefulWidget {
  const CreateDataInput({
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final void Function(DataInput) onSave;

  @override
  _CreateDataInputState createState() => _CreateDataInputState();
}

class _CreateDataInputState extends State<CreateDataInput> {
  InputTypes? type;
  String? name;
  String? description;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (type != null) {
      return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CMTextField(
                label: 'Name',
                validate: (value) => Validators().validateNotEmpty(
                  value,
                  'Name',
                ),
                onSaved: (value) {
                  name = value;
                },
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextField(
                label: 'Beschreibung',
                onSaved: (value) {
                  description = value ?? '';
                },
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextButton(
                child: Text('OK'),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    widget.onSave(
                      DataInput(
                        name: name!,
                        description: description!,
                        type: type!,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'Datentyp',
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: InputTypes.values.map((types) {
              return ListTile(
                title: Text(types.name),
                onTap: () {
                  setState(() {
                    type = types;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
