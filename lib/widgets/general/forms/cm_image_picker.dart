import 'dart:io';
import 'dart:typed_data';

import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/image_view.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:line_icons/line_icons.dart';

/// The picked image will be compressed and of type jpeg.
class CMImagePicker extends StatefulWidget {
  const CMImagePicker({
    this.saveImage,
    required this.imageFile,
    required this.heroTag,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  ///Will be called after the image is picked & compressed or deleted.
  /// Image bytes + path.
  final void Function(Uint8List?, String?)? saveImage;
  final CMImage imageFile;
  final bool enabled;
  final String heroTag;

  @override
  _CMImagePickerState createState() => _CMImagePickerState();
}

class _CMImagePickerState extends State<CMImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,

          /// Align needs this to work as intended.
          child: Stack(
            children: <Widget>[
              Hero(
                tag: ValueKey(widget.heroTag),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageView(
                            heroTag: widget.heroTag,
                            image: widget.imageFile.imageProvider,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: widget.imageFile.imageProvider ??
                                const AssetImage(
                                  'assets/images/designer_edited.jpg',
                                ),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(
                          SizeConfig.baseBorderRadius,
                        ),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.enabled)
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.6),
                        ),
                        alignment: Alignment.center,
                        child: Icon(LineIcons.camera),
                      ),
                      onPressed: () async {
                        bool? success = await _showPicker(context);
                        success ??= false;
                        if (!success) {
                          _showErrorDialog();
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.imageFile.imageProvider != null)
          CMTextButton(
            primary: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            child: Text('REMOVE'),
            onPressed: _deleteImage,
          ),
      ],
    );
  }

  void _deleteImage() {
    setState(() {
      widget.imageFile.imageProvider = null;
      if (widget.saveImage != null) {
        widget.saveImage!(null, null);
      }
    });
  }

  Future<void> _saveImage(File img) async {
    final result = await _compressImage(img);
    if (result == null) {
      return;
    }
    img.writeAsBytesSync(result);
    setState(() {
      widget.imageFile.imageProvider = MemoryImage(result);
      widget.imageFile.path = img.path;
      if (widget.saveImage != null) {
        widget.saveImage!(result, img.path);
      }
    });
  }

  Future<Uint8List?> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 400,
      minHeight: 400,
      quality: 90,
    );
    return result;
  }

  Future<bool> _imgFromCamera() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (image == null) {
      return false;
    }
    _saveImage(File(image.path));
    return true;
  }

  Future<bool> _imgFromGallery() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return false;
    }
    _saveImage(File(image.path));
    return true;
  }

  Future<bool?> _showPicker(context) async {
    return showModalBottomSheet<bool>(
      elevation: SizeConfig.baseBackgroundElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(SizeConfig.baseBorderRadius),
          topLeft: Radius.circular(SizeConfig.baseBorderRadius),
        ),
      ),
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                ),
                title: Text('Galerie'),
                onTap: () async {
                  final bool success = await _imgFromGallery();
                  Navigator.of(context).pop(success);
                },
              ),
              ListTile(
                leading: Icon(
                  LineIcons.camera,
                ),
                title: Text('Kamera'),
                onTap: () async {
                  final bool success = await _imgFromCamera();
                  Navigator.of(context).pop(success);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog() {
    CoolAlert.show(
      context: context,
      type: CoolAlertType.warning,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Auswahl fehlgeschlagen oder abgebrochen.',
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
