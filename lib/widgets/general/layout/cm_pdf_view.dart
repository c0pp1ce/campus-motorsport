import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class CMPdfView extends StatefulWidget {
  const CMPdfView({
    required this.filePath,
    Key? key,
  }) : super(key: key);

  final String filePath;

  @override
  _CMPdfViewState createState() => _CMPdfViewState();
}

class _CMPdfViewState extends State<CMPdfView> {
  late final PdfController pdfController;

  @override
  void initState() {
    super.initState();
    pdfController = PdfController(
      document: PdfDocument.openFile(widget.filePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: MainView.appBarElevation,
      ),
      body: PdfView(
        controller: pdfController,
      ),
    );
  }
}
