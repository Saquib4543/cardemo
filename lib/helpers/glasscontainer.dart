import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final Color? color;

  GlassContainer({this.child, this.blur = 15, this.borderRadius, this.padding,this.height, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.9),
            spreadRadius: 3,
            blurRadius: blur!,
            offset: Offset(-10, -10),
          ),
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.9),
            spreadRadius: 1,
            blurRadius: blur!,
            offset: Offset(10, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur!, sigmaY: blur!),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(15),
              color: Colors.yellow.withOpacity(0.9),
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.all(10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
