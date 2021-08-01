import 'package:campus_motorsport/widgets/general/stacked_ui/main_view.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  const ImageView({
    required this.heroTag,
    this.image,
    Key? key,
  }) : super(key: key);

  final ImageProvider? image;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: MainView.appBarElevation,
      ),
      body: Center(
        child: Hero(
          tag: ValueKey(heroTag),
          child: SizedBox(
            height: double.infinity,
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.zero,
              minScale: 0.5,
              maxScale: 2.5,
              child: Image(
                image: image ??
                    const AssetImage('assets/images/designer_edited.jpg'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
