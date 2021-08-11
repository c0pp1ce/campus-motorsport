import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/models/component_containers/component_container.dart';
import 'package:campus_motorsport/provider/component_containers/cc_provider.dart';
import 'package:campus_motorsport/provider/component_containers/cc_view_provider.dart';
import 'package:campus_motorsport/provider/global/current_user.dart';
import 'package:campus_motorsport/repositories/firebase_crud/crud_comp_container.dart';
import 'package:campus_motorsport/services/color_services.dart';
import 'package:campus_motorsport/services/validators.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/component_containers/current_state_overview.dart';
import 'package:campus_motorsport/widgets/component_containers/state_updates.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_image_picker.dart';
import 'package:campus_motorsport/widgets/general/forms/cm_text_field.dart';
import 'package:campus_motorsport/widgets/general/layout/expanded_appbar.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_list.dart';
import 'package:campus_motorsport/widgets/component_containers/unused_components.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

/// Displays the current state as well as provides editing functionality.
class CurrentState extends StatefulWidget {
  const CurrentState({
    Key? key,
  }) : super(key: key);

  static final Color notUpdated = Colors.grey;
  static final Color badState = Colors.redAccent;
  static final Color okState = Colors.yellowAccent;
  static final Color newState = Colors.greenAccent;

  static double tileStateColorOpacity = 0.05;

  @override
  _CurrentStateState createState() => _CurrentStateState();
}

class _CurrentStateState extends State<CurrentState> {
  bool edit = false;
  bool loading = false;
  late TextEditingController _nameController;
  late CMImage image;

  @override
  void initState() {
    _nameController = TextEditingController();
    _nameController.text =
        context.read<CCViewProvider>().currentlyOpen?.name ?? '';
    image = context
            .read<CCViewProvider>()
            .currentlyOpen
            ?.image
            ?.cloneNetworkImage() ??
        CMImage();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CCViewProvider viewProvider = context.watch<CCViewProvider>();

    /// Some error occurred.
    if (viewProvider.currentlyOpen == null) {
      const ExpandedAppBar(
        appbarTitle: Text('Fehler beim Laden.'),
        offsetBeforeTitleShown: 0,
        appbarChild: Center(
          child: Text('Fehler beim Laden.'),
        ),
      );
    }

    final bool isAdmin = context.watch<CurrentUser>().user?.isAdmin ?? false;

    return ExpandedAppBar(
      onRefresh: viewProvider.reloadCurrentlyOpen,
      loadingListener: (value) {
        setState(() {
          loading = value;
        });
      },
      offsetBeforeTitleShown: 5,
      expandedHeight: edit ? 250 : 210,
      appbarTitle: isAdmin && edit
          ? CMTextField(
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: edit ? Theme.of(context).colorScheme.primary : null,
                  ),
              controller: _nameController,
              enabled: edit,
              noBorders: true,
            )
          : Text(
              viewProvider.currentlyOpen!.name,
              style: Theme.of(context).textTheme.headline6,
            ),
      titleAlwaysVisible: true,
      appbarChild: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SizeConfig.basePadding,
            ),
            child: CMImagePicker(
              imageFile: image,
              heroTag: viewProvider.currentlyOpen!.id!,
              enabled: edit,
              roundedBottom: true,
            ),
          ),
        ],
      ),
      actions: isAdmin ? _buildActions(context, viewProvider) : null,
      body: loading
          ? const LoadingList()
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SizeConfig.basePadding,
              ),
              child: Column(
                children: <Widget>[
                  const CurrentStateOverview(),
                  const SizedBox(
                    height: SizeConfig.basePadding * 2,
                  ),
                  StateUpdates(
                    updates: viewProvider.currentlyOpen!.currentState,
                  ),
                  const SizedBox(
                    height: SizeConfig.basePadding * 2,
                  ),
                  UnusedComponents(
                    isAdmin: isAdmin,
                    key: ValueKey(viewProvider.currentlyOpen!.id!),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildActions(
      BuildContext context, CCViewProvider viewProvider) {
    if (loading) {
      return [
        Container(
          height: 50,
          width: 55,
          padding: const EdgeInsets.all(SizeConfig.basePadding),
          child: const CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ];
    }
    return [
      if (edit)

        /// Delete button
        IconButton(
          onPressed: () => _showDeleteDialog(viewProvider.currentlyOpen!),
          icon: Icon(
            LineIcons.trash,
            color: ColorServices.darken(
              Theme.of(context).colorScheme.secondary,
              20,
            ),
          ),
          splashRadius: SizeConfig.iconButtonSplashRadius,
        ),
      if (!edit)

        /// Edit button
        IconButton(
          onPressed: () {
            setState(() {
              edit = true;
            });
          },
          icon: Icon(
            LineIcons.edit,
          ),
          splashRadius: SizeConfig.iconButtonSplashRadius,
        )
      else ...[
        /// Cancel edit button
        IconButton(
          onPressed: () {
            setState(() {
              reset(viewProvider);
              edit = false;
            });
          },
          icon: Icon(
            Icons.close,
          ),
          splashRadius: SizeConfig.iconButtonSplashRadius,
        ),

        /// Save button
        IconButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            final bool success = await _saveChanges(viewProvider);
            setState(() {
              loading = false;
            });
            if (success) {
              setState(() {
                edit = false;
              });
            } else {
              _showErrorDialog('Fehler beim Speichern.');
            }
          },
          icon: Icon(
            LineIcons.save,
          ),
          splashRadius: SizeConfig.iconButtonSplashRadius,
        ),
      ],
    ];
  }

  void reset(CCViewProvider viewProvider) {
    _nameController.text = viewProvider.currentlyOpen!.name;
    image = viewProvider.currentlyOpen!.image?.cloneNetworkImage() ?? CMImage();
  }

  Future<bool> _saveChanges(CCViewProvider viewProvider) async {
    final String name = _nameController.value.text;
    if (Validators().validateNotEmpty(name, 'Name') != null) {
      _showErrorDialog('Name darf nicht leer sein.');
      return false;
    }
    final bool nameChanged = name != viewProvider.currentlyOpen!.name;
    late bool imageChanged;

    if (viewProvider.currentlyOpen!.image?.url != null) {
      if (viewProvider.currentlyOpen!.image?.url != image.url) {
        imageChanged = true;
      } else {
        imageChanged = false;
      }
    } else if (viewProvider.currentlyOpen!.image == null) {
      if (image.imageProvider != null) {
        imageChanged = true;
      } else {
        imageChanged = false;
      }
    } else {
      print('unhandled image change case'); // TODO : Remove
      imageChanged = false;
    }

    if (!nameChanged && !imageChanged) {
      return true;
    }

    final data = <String, dynamic>{};
    if (nameChanged) {
      data['name'] = name;
    }

    /// Check if image got deleted.
    if (imageChanged) {
      if (viewProvider.currentlyOpen!.image?.url != null &&
          image.imageProvider == null) {
        await viewProvider.currentlyOpen!.image!.deleteFromFirebase();
        imageChanged = false;
        data['image'] = '';
      }
    }

    /// New image got selected
    if (imageChanged) {
      await image.uploadImageToFirebaseStorage(viewProvider.currentlyOpen!.id!);
      assert(image.url != null, 'Upload failed');
      data['image'] = image.url;
    }

    final bool success = await CrudCompContainer().updateContainer(
      docId: viewProvider.currentlyOpen!.id!,
      data: data,
    );
    if (success) {
      await viewProvider.reloadCurrentlyOpen();
      setState(() {
        reset(viewProvider);
      });
      return true;
    }
    return false;
  }

  void _showErrorDialog(String title) {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: title,
      text: 'Da ist wohl etwas schiefgelaufen.',
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

  void _showDeleteDialog(ComponentContainer container) {
    CoolAlert.show(
      barrierDismissible: false,
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Löschen bestätigen.',
      text: '',
      widget: RichText(
        text: TextSpan(
          text: 'Willst du ',
          children: <TextSpan>[
            TextSpan(
              text: '${container.name} ',
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
            TextSpan(
              text: 'wirklich löschen?',
            ),
          ],
        ),
      ),
      confirmButton: Padding(
        padding: const EdgeInsets.only(left: SizeConfig.basePadding / 2),
        child: CMTextButton(
          child: const Text(
            'JA',
          ),
          onPressed: () async {
            setState(() {
              loading = true;
            });

            /// Leave dialog in order to avoid stacked dialogs.
            Navigator.of(context).pop();

            /// Try to delete the container.
            final bool success = await CrudCompContainer().deleteContainer(
              container.id!,
            );
            if (success) {
              // TODO : Probably error check as well.
              if (container.image?.url != null) {
                await container.image!.deleteFromFirebase();
              }
            }
            setState(() {
              loading = false;
            });
            if (!success) {
              _showErrorDialog('Fehler beim Löschen.');
            } else {
              // TODO : Add remove function to avoid those expensive reloads.
              switch (container.type) {
                case ComponentContainerTypes.stock:
                  context.read<StocksProvider>().reload(false);
                  break;
                case ComponentContainerTypes.vehicle:
                  context.read<VehiclesProvider>().reload(false);
                  break;
              }
            }
          },
        ),
      ),
      showCancelBtn: true,
      cancelButton: Padding(
        padding: const EdgeInsets.only(right: SizeConfig.basePadding / 2),
        child: CMTextButton(
          primary: Theme.of(context).colorScheme.onSurface,
          child: const Text(
            'ABBRECHEN',
          ),
          gradient: LinearGradient(
            colors: <Color>[
              ColorServices.brighten(
                Theme.of(context).colorScheme.surface.withOpacity(0.7),
                25,
              ),
              Theme.of(context).colorScheme.surface.withOpacity(0.9),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      loopAnimation: false,
    );
  }
}
