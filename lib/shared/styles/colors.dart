import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

Color seedColor = HexColor('5CE1E6');//Colors.indigoAccent;

// Light and dark color schemes using `ColorScheme.fromSeed`
final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.dark,
);


//----------------------------------------

//LIGHT MODE


Color defaultColor= lightColorScheme.primary;

Color defaultHomeColor= lightColorScheme.surface;

Color defaultSecondaryColor= lightColorScheme.secondary;

Color defaultThirdColor= lightColorScheme.tertiary;

Color defaultFontColor= Colors.white;


//----------------------------------------

//DARK MODE

Color defaultDarkColor= darkColorScheme.primary;

Color defaultHomeDarkColor = darkColorScheme.surface;

Color defaultSecondaryDarkColor= darkColorScheme.secondary;

Color defaultThirdDarkColor= darkColorScheme.tertiary;

Color defaultDarkFontColor= Colors.black;
