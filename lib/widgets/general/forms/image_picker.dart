import 'dart:io';
import 'dart:typed_data';

import 'package:campus_motorsport/models/cm_image.dart';
import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:line_icons/line_icons.dart';

/// The picked image will be compressed and of type jpeg.
class CMImagePicker extends StatefulWidget {
  const CMImagePicker({
    required this.saveImage,
    required this.imageFile,
    Key? key,
  }) : super(key: key);

  ///Will be called after the image is picked & compressed or deleted.
  final void Function(Uint8List?) saveImage;
  final CMImage imageFile;

  @override
  _CMImagePickerState createState() => _CMImagePickerState();
}

class _CMImagePickerState extends State<CMImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140.0,
          width: 140.0,
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: widget.imageFile.imageProvider ??
                            AssetImage(
                              'assets/images/profile_dummy_image.png',
                            ),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(
                      SizeConfig.baseBorderRadius,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 52,
                  width: 52,
                  child: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow, // TODO
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
      widget.saveImage(null);
    });
  }

  Future<void> _saveImage(File img) async {
    final result = await _compressImage(img);
    if (result == null) {
      return;
    }
    setState(() {
      widget.imageFile.imageProvider = MemoryImage(result);
      widget.saveImage(result);
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
      type: CoolAlertType.error,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: 'Speichern fehlgeschlagen.',
      text: 'Das ausgewählte Bild konnte nicht gespeichert werden.\n'
          'Bitte probiere es erneut.',
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
