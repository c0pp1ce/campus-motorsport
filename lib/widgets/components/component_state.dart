import 'package:campus_motorsport/models/components/component.dart' as model;
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

  final void Function(model.ComponentState) onSaved;
  final model.ComponentState? initialState;
  final bool enabled;
  final bool highlightInput;

  @override
  _ComponentStateState createState() => _ComponentStateState();
}

class _ComponentStateState extends State<ComponentState> {
  model.ComponentState? currentState;

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
            value: model.ComponentState.values
                .indexOf(currentState ?? model.ComponentState.bad)
                .toDouble(),
            min: 0,
            max: model.ComponentState.values.length.toDouble() - 1,
            divisions: model.ComponentState.values.length - 1,
            label: currentState?.name,
            onChanged: !widget.enabled
                ? null
                : (value) {
                    final int index = value.round();
                    setState(() {
                      currentState = model.ComponentState.values[index];
                      widget.onSaved(model.ComponentState.values[index]);
                    });
                  },
          ),
        ),
      ],
    );
  }

  Color get stateColor {
    switch (currentState ?? model.ComponentState.bad) {
      case model.ComponentState.bad:
        return CurrentState.badState;
      case model.ComponentState.ok:
        return CurrentState.okState;
      case model.ComponentState.newComponent:
        return CurrentState.newState;
    }
  }
}
