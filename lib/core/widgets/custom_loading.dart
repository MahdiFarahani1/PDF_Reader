import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key, this.color});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      size: 35,
      color: color ?? Theme.of(context).primaryColor,
    );
  }
}
