import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tech_gadol/ui/common/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.color, this.size});
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.hexagonDots(
        color: color ?? whiteColor,
        size: size ?? 30,
      ),
    );
  }
}
