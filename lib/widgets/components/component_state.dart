import 'package:campus_motorsport/models/components/component.dart';
import 'package:campus_motorsport/views/main/pages/component_containers/current_state.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_label.dart';
import 'package:flutter/material.dart';

class ComponentState extends StatefulWidget {
  const ComponentState({
    required this.onSaved,
    required this.highlightInput,
    this.initialState,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  final void Function(ComponentStates) onSaved;
  final ComponentStates? initialState;
  final bool enabled;
  final bool highlightInput;

  @override
  _ComponentStateState createState() => _ComponentStateState();
}

class _ComponentStateState extends State<ComponentState> {
  ComponentStates? currentState;

  @override
  void initState() {
    super.initState();
    currentState = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CMLabel(
          label: 'Zustand',
          darken: widget.highlightInput,
        ),
        SliderTheme(
          data: Theme.of(context).sliderTheme.copyWith(
                disabledActiveTrackColor: stateColor,
                activeTrackColor: stateColor,
              ),
          child: Slider(
            value: ComponentStates.values
                .indexOf(currentState ?? ComponentStates.bad)
                .toDouble(),
            min: 0,
            max: ComponentStates.values.length.toDouble() - 1,
            divisions: ComponentStates.values.length - 1,
            label: currentState?.name,
            onChanged: !widget.enabled
                ? null
                : (value) {
                    final int index = value.round();
                    setState(() {
                      currentState = ComponentStates.values[index];
                      widget.onSaved(ComponentStates.values[index]);
                    });
                  },
          ),
        ),
      ],
    );
  }

  Color get stateColor {
    switch (currentState ?? ComponentStates.bad) {
      case ComponentStates.bad:
        return CurrentState.badState;
      case ComponentStates.ok:
        return CurrentState.okState;
      case ComponentStates.newComponent:
        return CurrentState.newState;
    }
  }
}
