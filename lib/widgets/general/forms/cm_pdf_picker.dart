import 'dart:io';
import 'dart:typed_data';

import 'package:campus_motorsport/utilities/size_config.dart';
import 'package:campus_motorsport/widgets/general/buttons/cm_text_button.dart';
import 'package:campus_motorsport/widgets/general/layout/cm_pdf_view.dart';
import 'package:campus_motorsport/widgets/general/layout/loading_item.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class CMPdfPicker extends StatelessWidget {
  const CMPdfPicker({
    required this.savePdf,
    required this.heroTag,
    this.filePath,
    this.enabled = true,
    this.roundedBottom = true,
    this.loading = false,
    Key? key,
  }) : super(key: key);

  ///Will be called after the pdf is picked or deleted.
  /// bytes + path.
  final void Function(Uint8List?, String?) savePdf;
  final bool enabled;
  final String heroTag;
  final bool roundedBottom;
  final String? filePath;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingItem(
        child: Container(
          height: 180,
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: Stack(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (filePath != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CMPdfView(
                            filePath: filePath!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: roundedBottom
                          ? BorderRadius.circular(
                              SizeConfig.baseBorderRadius,
                            )
                          : const BorderRadius.vertical(
                              top: Radius.circular(
                                SizeConfig.baseBorderRadius,
                              ),
                            ),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: filePath != null
                        ? Center(
                            child: Text(
                              'DATEI ÖFFNEN',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(
                                    fontSize: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (enabled)
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Material(
                      color: Colors.transparent,
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
                          child: Icon(LineIcons.file),
                        ),
                        splashRadius: SizeConfig.iconButtonSplashRadius,
                        onPressed: () async {
                          final bool success = await pickPdf();
                          if (!success) {
                            _showErrorDialog(context);
                          }
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (enabled && filePath != null)
          CMTextButton(
            primary: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.transparent,
            child: Text('ENTFERNEN'),
            onPressed: _deleteFile,
          ),
      ],
    );
  }

  void _deleteFile() {
    savePdf(null, null);
  }

  Future<bool> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowCompression: true,
    );

    if (result != null) {
      final PlatformFile file = result.files.first;
      late final Uint8List bytes;
      if (file.path == null) {
        return false;
      }
      if (file.bytes == null) {
        bytes = File(file.path!).readAsBytesSync();
      } else {
        bytes = file.bytes!;
      }
      savePdf(bytes, file.path);
      return true;
    } else {
      return false;
    }
  }

  void _showErrorDialog(BuildContext context) {
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
