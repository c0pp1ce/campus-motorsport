import 'package:campus_motorsport/utilities/color_services.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingItem extends StatelessWidget {
  const LoadingItem({
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      period: const Duration(milliseconds: 1500),
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: ColorServices.brighten(
        Theme.of(context).colorScheme.surface,
        20,
      ),
      direction: ShimmerDirection.ltr,
    );
  }
}
