import 'package:flutter/material.dart';

Color light = Color.fromRGBO(220, 220, 220, 1);
Color dark = Color.fromRGBO(62, 63, 159, 1);
Color primary = Color.fromRGBO(242, 242, 242, 1);
Color secondary = Color.fromRGBO(62, 63, 159, 1);
Color grey = Color.fromRGBO(133, 133, 133, 1);
Color green = Color.fromRGBO(171, 223, 117, 1);
Color red = Color(0xffc2031f);
Color white = Color.fromRGBO(255, 255, 255, 1);
Color yellow = Colors.yellow; // For pure yellow
MaterialStateProperty<Color> lightMat = MaterialStateProperty.all(light);
MaterialStateProperty<Color> darkMat = MaterialStateProperty.all(dark);
MaterialStateProperty<Color> primaryMat = MaterialStateProperty.all(primary);
MaterialStateProperty<Color> secondaryMat =
    MaterialStateProperty.all(secondary);
MaterialStateProperty<Color> greyMat = MaterialStateProperty.all(grey);
MaterialStateProperty<Color> greenMat = MaterialStateProperty.all(green);
