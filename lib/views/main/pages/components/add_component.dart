import 'package:campus_motorsport/models/vehicle_components/data_input.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/components/create_data_input.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/general/forms/component_text.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_title.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class AddComponent extends StatefulWidget {
  const AddComponent({Key? key}) : super(key: key);

  @override
  _AddComponentState createState() => _AddComponentState();
}

class _AddComponentState extends State<AddComponent> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _loading = false;

  String? name;
  List<DataInput> additionalData = [];

  @override
  Widget build(BuildContext context) {
    return ExpandedAppBar(
      appbarTitle: const Text('Komponente erstellen'),
      appbarChild: const Center(
        child: ExpandedTitle(
          title: 'Komponente erstellen',
        ),
      ),
      actions: _loading
          ? []
          : [
              IconButton(
                onPressed: () {
                  // TODO : Save
                },
                icon: Icon(LineIcons.save),
                splashRadius: SizeConfig.iconButtonSplashRadius,
              ),
            ],
      offsetBeforeTitleShown: 70,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth,
      child: Padding(
        padding: const EdgeInsets.all(SizeConfig.basePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CMTextField(
                label: 'Name',
                maxLines: 1,
                textInputType: TextInputType.text,
                textInputAction: TextInputAction.done,
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
              // TODO Image picker
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              ComponentText(
                name: 'Anmerkungen',
                description: '',
                onSaved: (value) {},
                enabled: false,
                minLines: 2,
                maxLines: 4,
              ),
              _buildAdditionalData(context),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              Center(
                child: SizedBox(
                  width: SizeConfig.screenWidth / 2,
                  child: CMTextButton(
                    loading: _loading,
                    child: Icon(
                      LineIcons.plus,
                      size: 35,
                    ),
                    onPressed: () async {
                      final DataInput? dataInput =
                          await _showTypeSelection(context);
                      if (dataInput != null) {
                        setState(() {
                          additionalData.add(dataInput);
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalData(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: additionalData.map((dataInput) {
        switch (dataInput.type) {
          case InputTypes.text:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
              child: ComponentText(
                name: dataInput.name,
                description: dataInput.description,
                onSaved: (_) {},
                enabled: false,
              ),
            );
          case InputTypes.number:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
              child: ComponentText(
                name: dataInput.name,
                description: dataInput.description,
                onSaved: (_) {},
                enabled: false,
              ),
            );
          case InputTypes.date:
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
              child: ComponentText(
                name: dataInput.name,
                description: dataInput.description,
                onSaved: (_) {},
                enabled: false,
              ),
            );
        }
      }).toList(),
    );
  }

  Future<DataInput?> _showTypeSelection(BuildContext context) {
    return showModalBottomSheet<DataInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: SizeConfig.baseBackgroundElevation,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.baseBorderRadius),
          topRight: Radius.circular(SizeConfig.baseBorderRadius),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: CreateDataInput(
            onSave: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );
  }
}
