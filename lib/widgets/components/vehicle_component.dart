import 'package:campus_motorsport/models/component_containers/update.dart';
import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/models/components/data_input.dart';
import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:campus_motorsport/utilities/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/components/component_category.dart';
import 'package:campus_motorsport/widgets/components/component_date.dart';
import 'package:campus_motorsport/widgets/components/component_image.dart';
import 'package:campus_motorsport/widgets/components/component_number.dart';
import 'package:campus_motorsport/widgets/components/component_state.dart';
import 'package:campus_motorsport/widgets/components/component_text.dart';
import 'package:campus_motorsport/widgets/components/create_data_input.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// Read component, fill blueprint with data or create component.
class VehicleComponent extends StatefulWidget {
  const VehicleComponent({
    this.component,
    this.previousData,
    this.create = false,
    this.fillWithData = false,
    this.read = true,
    this.nameController,
    this.categoryKey,
    this.formKey,
    this.showBaseData = true,
    this.onEventCounterSave,
    this.highlightInputs = false,
    this.currentEventCounter,
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

  /// Used to show the previous updates data when adding a new one.
  final Update? previousData;
  // Workaround to also use this widget as details view for updates.
  final int? currentEventCounter;

  /// Create a component.
  final bool create;
  final bool fillWithData;
  final bool read;

  /// Only tested for read mode.
  final bool highlightInputs;

  /// Name, category, state
  final bool showBaseData;
  final TextEditingController? nameController;
  final GlobalKey<CMDropDownMenuState>? categoryKey;
  final GlobalKey<FormState>? formKey;
  final void Function(int?)? onEventCounterSave;

  /// Value by which titles and descriptions are darkened if inputs should be
  /// highlighted.
  static int darkenTextBy = SizeConfig.darkenTextColorBy ~/ 2;

  @override
  VehicleComponentState createState() => VehicleComponentState();
}

class VehicleComponentState extends State<VehicleComponent> {
  bool _loading = false;
  late final bool _previousDataFound;
  TextEditingController? baseEventCounterController;

  set loading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  /// If handed over.
  BaseComponent? baseComponent;
  List<DataInput>? additionalData;

  /// For component creation.
  String? name;
  ComponentCategories? category;
  int? baseEventCounter;

  @override
  void initState() {
    if (widget.create) {
      baseEventCounterController = TextEditingController();
    }
    if (widget.read || widget.fillWithData) {
      baseComponent = widget.component;
      category = widget.component!.category;
      if (widget.component is ExtendedComponent) {
        additionalData =
            (widget.component! as ExtendedComponent).additionalData;
      }
    }

    if (widget.previousData != null) {
      _previousDataFound = true;
    } else {
      _previousDataFound = false;
    }

    super.initState();
  }

  void reset() {
    baseEventCounter = null;
    baseEventCounterController?.clear();
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
                  highlightInput: widget.highlightInputs,
                  initialState: widget.previousData?.component.state ??
                      widget.component?.state,
                  enabled: widget.fillWithData,
                  onSaved: (value) {
                    baseComponent!.state = value;
                  },
                ),
                const SizedBox(
                  height: SizeConfig.basePadding * 2,
                ),
              ],
              if (widget.showBaseData) ..._showEventPicker(context),
              const SizedBox(
                height: SizeConfig.basePadding,
              ),
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
                          additionalData ??= [];
                          setState(() {
                            additionalData!.add(dataInput);
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
    additionalData ??= [];
    if (additionalData!.isEmpty && widget.read) {
      return Text(
        'Keine zusätzlichen Datenfelder.',
        style: Theme.of(context).textTheme.bodyText2?.copyWith(
              fontStyle: FontStyle.italic,
            ),
      );
    }

    if (additionalData!.isEmpty) {
      return const SizedBox();
    }

    /// Used to map previous data to the right data input.
    int index = 0;
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: additionalData!.map((dataInput) {
        index++;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              /// index - 1 as index needs to be incremented before the return statement.
              child: _getDataInputWidget(dataInput, index - 1),
            ),
            if (widget.create)
              IconButton(
                icon: Icon(
                  LineIcons.trash,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  setState(() {
                    additionalData!.remove(dataInput);
                  });
                },
              ),
          ],
        );
      }).toList(),
    );
  }

  /// Index of the dataInput inside of the additionalData list.
  /// Used to map previous data to the right dataInput.
  Widget _getDataInputWidget(DataInput dataInput, int index) {
    final DataInput? previousDataInput = _previousDataFound
        ? (widget.previousData!.component as ExtendedComponent)
            .additionalData[index]
        : null;
    const double padding = SizeConfig.basePadding * 2;

    switch (dataInput.type) {
      case InputTypes.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: ComponentText(
            highlightInput: widget.highlightInputs,
            dataInput: dataInput,
            previousData: previousDataInput,
            enabled: widget.fillWithData,
          ),
        );
      case InputTypes.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: ComponentNumber(
            highlightInput: widget.highlightInputs,
            dataInput: dataInput,
            enabled: widget.fillWithData,
            previousData: previousDataInput,
          ),
        );
      case InputTypes.date:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: ComponentDate(
            highlightInput: widget.highlightInputs,
            dataInput: dataInput,
            previousData: previousDataInput,
            enabled: widget.fillWithData,
          ),
        );
      case InputTypes.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: padding),
          child: ComponentImage(
            highlightInput: widget.highlightInputs,
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

  /// In creation mode the matching component attribute is set.
  ///
  /// For updates the onEventCounterSave function needs to be provided.
  List<Widget> _showEventPicker(BuildContext context) {
    return [
      CMLabel(
        label: widget.create ? 'Fahrtenzähler Grundwert' : 'Fahrtenzähler',
        darken: widget.highlightInputs,
      ),
      Text(
        widget.fillWithData || widget.read
            ? 'Anzahl an einzutragenden Fahrten bevor der Status automatisch geändert wird.\n\n'
                'Kein Wert = keine automatische Änderung.\n'
                'Kein Grundwert = Nach erreichen von 0 kein automatischer Reset.'
            : 'Grundwert für den Fahrtenzähler, auf den zurückgesetzt wird nachdem er 0 erreicht hat.\n\n'
                'Kein Grundwert = Nach erreichen von 0 kein automatischer Reset.',
        style: widget.highlightInputs
            ? Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: ColorServices.darken(
                    Theme.of(context).colorScheme.onSurface,
                    VehicleComponent.darkenTextBy,
                  ),
                )
            : null,
      ),
      const SizedBox(
        height: SizeConfig.basePadding,
      ),
      CMTextField(
        controller: baseEventCounterController,
        enabled: widget.create || widget.fillWithData,

        /// baseEventCounterController only in create mode != null.
        initialValue: baseEventCounterController == null
            ? (widget.previousData?.eventCounter ??
                    widget.currentEventCounter ??
                    baseComponent?.baseEventCounter ??
                    '')
                .toString()
            : null,
        onSaved: (value) {
          value ??= '';
          if (widget.onEventCounterSave != null) {
            widget.onEventCounterSave!(int.tryParse(value));
          }

          if (widget.create) {
            baseEventCounter = int.tryParse(value);
          }
        },
        minLines: 1,
        maxLines: 1,
        textInputType: TextInputType.numberWithOptions(
          decimal: false,
        ),
        textInputAction: TextInputAction.done,
        validate: (value) => Validators().validateIntValue(value),
      ),
      if (_previousDataFound) ...[
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        Text(
          'Vorheriger Wert',
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                color: ColorServices.darken(
                  Theme.of(context).colorScheme.onSurface,
                  SizeConfig.darkenTextColorBy,
                ),
              ),
        ),
        Text(
          widget.previousData?.eventCounter?.toString() ?? 'Nicht gesetzt.',
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: ColorServices.darken(
                  Theme.of(context).colorScheme.onSurface,
                  SizeConfig.darkenTextColorBy,
                ),
              ),
        ),
      ],
      if (!widget.create) ...[
        const SizedBox(
          height: SizeConfig.basePadding,
        ),
        Text(
          'Grundwert',
          style: Theme.of(context).textTheme.subtitle2?.copyWith(
                color: ColorServices.darken(
                  Theme.of(context).colorScheme.onSurface,
                  SizeConfig.darkenTextColorBy,
                ),
              ),
        ),
        Text(
          widget.component?.baseEventCounter?.toString() ?? 'Nicht gesetzt.',
          style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: ColorServices.darken(
                  Theme.of(context).colorScheme.onSurface,
                  SizeConfig.darkenTextColorBy,
                ),
              ),
        ),
      ],
    ];
  }
}
