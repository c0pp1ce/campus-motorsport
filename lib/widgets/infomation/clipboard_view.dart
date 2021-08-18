import 'package:campus_motorsport/models/clipboard.dart';
import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/provider/information/clipboard_provider.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_drop_down_menu.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_image_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class ClipboardView extends StatefulWidget {
  const ClipboardView({
    required this.standAlone,
    this.clipboard,
    this.edit = false,
    this.create = false,
    this.loadingListener,
    this.clipboardProvider,
    Key? key,
  })  : assert((edit && !create) || (!edit && create) || (!edit && !create)),
        assert((edit && standAlone && clipboardProvider != null) ||
            (standAlone && !edit && !create) ||
            !standAlone),
        super(key: key);

  final bool standAlone;
  final bool create;
  final bool edit;
  final Clipboard? clipboard;
  final void Function(bool)? loadingListener;
  final ClipboardProvider? clipboardProvider;

  @override
  ClipboardViewState createState() => ClipboardViewState();
}

class ClipboardViewState extends State<ClipboardView> {
  /// Only used in edit mode.
  bool _loading = false;
  bool disposed = false;

  String? name;
  String? content;
  CpTypes? type;
  CMImage? image;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<CMDropDownMenuState> _dropDownKey = GlobalKey();
  TextEditingController? nameController;
  TextEditingController? contentController;

  void reset() {
    name = widget.clipboard?.name;
    content = widget.clipboard?.content;
    type = widget.clipboard?.type;
    _dropDownKey.currentState?.reset();

    if (widget.create) {
      nameController?.clear();
      contentController?.clear();
    }
    if (widget.edit) {
      nameController?.clear();
      nameController?.text = name ?? '';
      contentController?.clear();
      contentController?.text = content ?? '';
    }

    setState(() {});
  }

  @override
  void initState() {
    name = widget.clipboard?.name;
    content = widget.clipboard?.content;
    type = widget.clipboard?.type;

    if (widget.create) {
      nameController = TextEditingController();
      contentController = TextEditingController();
      image = CMImage();
    } else if (widget.edit) {
      nameController = TextEditingController();
      nameController?.text = name ?? '';
      contentController = TextEditingController();
      contentController?.text = content ?? '';
      image = widget.clipboard?.image;
    } else {
      image = widget.clipboard?.image;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    disposed = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    disposed = true;
    nameController?.dispose();
    contentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget boardView = _buildBoardView();

    if (widget.standAlone) {
      return Scaffold(
        backgroundColor: ElevationOverlay.applyOverlay(
          context,
          Theme.of(context).colorScheme.surface,
          SizeConfig.baseBackgroundElevation - 2,
        ),
        appBar: AppBar(
          elevation: MainView.appBarElevation,
          title: Text(
            name ?? 'Clipboard',
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: _buildActions(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: SizeConfig.basePadding * 2),
          physics: const BouncingScrollPhysics(),
          child: boardView,
        ),
      );
    } else {
      return boardView;
    }
  }

  Widget _buildBoardView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.basePadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (!widget.create &&
                !widget.edit &&
                widget.clipboard?.image != null) ...[
              CMImagePicker(
                imageFile: image!,
                heroTag: 'readClipboard',
                enabled: widget.create,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
            ],
            if (widget.edit || widget.create) ...[
              CMTextField(
                initialValue: nameController == null ? name : null,
                enabled: true,
                controller: nameController,
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
              CMDropDownMenu(
                key: _dropDownKey,
                initialValue: type?.name,
                enabled: true,
                values: CpTypes.values.map((e) => e.name).toList(),
                onSelect: (value) {
                  setState(
                    () {
                      for (final cType in CpTypes.values) {
                        if (value == cType.name) {
                          type = cType;
                          return;
                        }
                      }
                      type = null;
                    },
                  );
                },
                label: 'Kategorie',
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMImagePicker(
                imageFile: image ?? CMImage(),
                heroTag: 'createEditClipboard',
                enabled: widget.create,
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              CMTextField(
                initialValue: contentController == null ? name : null,
                enabled: true,
                controller: contentController,
                label: 'Inhalt',
                minLines: 1,
                maxLines: 30,
                textInputType: TextInputType.multiline,
                validate: (value) => Validators().validateNotEmpty(
                  value,
                  'Inhalt',
                ),
                onChanged: (value) {
                  setState(() {
                    content = value;
                  });
                },
                onSaved: (value) {
                  content = value;
                },
              ),
              const SizedBox(
                height: SizeConfig.basePadding * 2,
              ),
              Text(
                'Ausgabe',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: ColorServices.darken(
                        Theme.of(context).colorScheme.onSurface,
                        SizeConfig.darkenTextColorBy,
                      ),
                    ),
              ),
              Text(
                'Styling mit Markdown ist möglich.',
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: ColorServices.darken(
                        Theme.of(context).colorScheme.onSurface,
                        SizeConfig.darkenTextColorBy,
                      ),
                    ),
              ),
              const SizedBox(
                height: SizeConfig.basePadding,
              ),
            ],
            MarkdownBody(
              data: content ?? '',
              selectable: false,
            ),
            const SizedBox(
              height: SizeConfig.basePadding * 2,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget>? _buildActions() {
    return widget.edit
        ? [
            if (_loading)
              Container(
                height: 50,
                width: 55,
                padding: const EdgeInsets.all(SizeConfig.basePadding),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            if (!_loading)
              IconButton(
                onPressed: () async {
                  await save();
                },
                icon: Icon(
                  LineIcons.save,
                  size: 30,
                ),
                splashRadius: SizeConfig.iconButtonSplashRadius,
              ),
          ]
        : null;
  }

  Future<void> save() async {
    if (!widget.create && !widget.edit) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (widget.loadingListener != null) {
        widget.loadingListener!(true);
      }
      if (widget.edit) {
        setState(() {
          _loading = true;
        });
      }

      if (widget.create) {
        final Clipboard cb = Clipboard(
          name: name!,
          content: content!,
          type: type!,
          image: image,
        );
        final success = widget.standAlone
            ? await widget.clipboardProvider!.create(cb)
            : await context.read<ClipboardProvider>().create(cb);
        if (widget.loadingListener != null) {
          widget.loadingListener!(false);
        }
        if (!success) {
          _showErrorDialog(context);
        } else {
          if (!disposed) {
            reset();
          }
        }
        return;
      } else {
        if (widget.clipboard?.id == null) {
          if (widget.loadingListener != null) {
            widget.loadingListener!(false);
          }
          if (widget.edit) {
            setState(() {
              _loading = false;
            });
          }
          _showErrorDialog(context);
          return;
        }

        /// Editing.
        final Map<String, dynamic> data = {};
        if (name != widget.clipboard?.name) {
          data['name'] = name;
        }
        if (type != widget.clipboard?.type) {
          data['type'] = type?.name;
        }
        if (content != widget.clipboard?.content) {
          data['content'] = content;
        }

        final success = widget.standAlone
            ? await widget.clipboardProvider!.update(
                widget.clipboard!.id!,
                data,
              )
            : await context.read<ClipboardProvider>().update(
                  widget.clipboard!.id!,
                  data,
                );
        if (widget.loadingListener != null) {
          widget.loadingListener!(false);
        }
        if (widget.edit) {
          setState(() {
            _loading = false;
          });
        }
        if (!success) {
          _showErrorDialog(context);
        } else {
          if (widget.standAlone) {
            Navigator.of(context).pop();
          }
        }
      }
    }
  }

  void _showErrorDialog(BuildContext context) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: '',
      confirmButton: Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SizeConfig.basePadding * 2,
          ),
          child: CMTextButton(
            child: const Text(
              'VERSTANDEN',
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      loopAnimation: false,
    );
  }
}