import 'package:campus_motorsport/models/vehicle_components/component.dart';
import 'package:campus_motorsport/models/vehicle_components/data_input.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/components/component_category.dart';
import 'package:campus_motorsport/widgets/general/components/component_date.dart';
import 'package:campus_motorsport/widgets/general/components/component_image.dart';
import 'package:campus_motorsport/widgets/general/components/component_number.dart';
import 'package:campus_motorsport/widgets/general/components/component_state.dart';
import 'package:campus_motorsport/widgets/general/components/component_text.dart';
import 'package:campus_motorsport/widgets/general/components/create_data_input.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Read component, fill blueprint with data or create component.
class VehicleComponent extends StatefulWidget {
  const VehicleComponent({
    this.component,
    this.create = false,
    this.fillWithData = false,
    this.read = true,
    this.nameController,
    this.categoryKey,
    this.formKey,
    this.showBaseData = true,
    Key? key,
  })  : assert(
          (create && !fillWithData && !read) ||
              (!create && fillWithData && !read) ||
              (!create && !fillWithData && read),
          'Only one access mode allowed.',
        ),
        assert(
          ((fillWithData || read) && component != null) ||
              (!fillWithData && !read),
          'component needs to be provided to be able to fill or read it.',
        ),
        super(key: key);

  final BaseComponent? component;

  /// Create a component.
  final bool create;
  final bool fillWithData;
  final bool read;

  /// Name, category, state
  final bool showBaseData;
  final TextEditingController? nameController;
  final GlobalKey<CMDropDownMenuState>? categoryKey;
  final GlobalKey<FormState>? formKey;

  @override
  VehicleComponentState createState() => VehicleComponentState();
}

class VehicleComponentState extends State<VehicleComponent> {
  bool _loading = false;

  set loading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  /// If handed over.
  BaseComponent? baseComponent;

  /// For component creation.
  String? name;
  ComponentCategories? category;
  List<DataInput> additionalData = [];

  @override
  void initState() {
    if (widget.read || widget.fillWithData) {
      baseComponent = widget.component;
      category = widget.component!.category;
      if (widget.component is ExtendedComponent) {
        additionalData =
            (widget.component! as ExtendedComponent).additionalData;
      }
    }
    super.initState();
  }

  void reset() {
    name = null;
    category = null;
    additionalData = [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeConfig.basePadding),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.create) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Hinweis: ',
                    ),
                    Expanded(
                      child: Text(
                        'Datum und Durchführer einer Wartung werden nicht in der Komponente gespeichert. '
                        'Ein Datenfeld ist dafür also nicht nötig.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: SizeConfig.basePadding * 2,
                ),
              ],
              if (widget.showBaseData) ...[
                CMTextField(
                  initialValue: widget.component?.name,
                  enabled: widget.create,
                  controller: widget.nameController,
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
                ComponentCategory(
                  initialValue: widget.component?.category.name,
                  enabled: widget.create,
                  onSaved: (value) {
                    for (final ComponentCategories c
                        in ComponentCategories.values) {
                      if (c.name == value) {
                        setState(() {
                          category = c;
                        });
                        break;
                      }
                    }
                  },
                  dropDownKey: widget.categoryKey,
                ),
                const SizedBox(
                  height: SizeConfig.basePadding * 2,
                ),
                ComponentState(
                  initialState: widget.component?.state,
                  enabled: widget.fillWithData,
                  onSaved: (value) {
                    baseComponent!.state = value;
                  },
                ),
                const SizedBox(
                  height: SizeConfig.basePadding * 2,
                ),
              ],
              _buildAdditionalData(context),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              if (widget.create)
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
    if (additionalData.isEmpty && widget.read) {
      return Text(
        'Keine zusätzlichen Datenfelder.',
        style: Theme.of(context).textTheme.bodyText2?.copyWith(
              fontStyle: FontStyle.italic,
            ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: additionalData.map((dataInput) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: _getDataInputWidget(dataInput),
            ),
            if (widget.create)
              IconButton(
                icon: Icon(
                  LineIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  setState(() {
                    additionalData.remove(dataInput);
                  });
                },
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _getDataInputWidget(DataInput dataInput) {
    switch (dataInput.type) {
      case InputTypes.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentText(
            dataInput: dataInput,
            enabled: widget.fillWithData,
          ),
        );
      case InputTypes.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentNumber(
            dataInput: dataInput,
            enabled: widget.fillWithData,
          ),
        );
      case InputTypes.date:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentDate(
            dataInput: dataInput,
            enabled: widget.fillWithData,
          ),
        );
      case InputTypes.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: SizeConfig.basePadding),
          child: ComponentImage(
            dataInput: dataInput,
            enabled: widget.fillWithData,
          ),
        );
    }
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
