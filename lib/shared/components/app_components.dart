import 'dart:ui';

import 'package:hexcolor/hexcolor.dart';
import 'Imports/default_imports.dart';

///Checks if a String is numeric
bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

///Generate Colors
List<Color> generateHarmoniousColors(ColorScheme colorScheme, {int count = 10, bool isRainbow=true}) {

  if(isRainbow)
  {
    //List Of Rainbow colors
    List<Color> preferred=
    [
      HexColor('3ac7fd'),
      HexColor('0bcee0'),
      HexColor('5dda76'),
      HexColor('fdfc2e'),
      HexColor('fec321'),
      HexColor('ff8c56'),
      HexColor('ff3b2b'),
      HexColor('ff4433'),
      HexColor('bb4fb4'),
      HexColor('9b5ac0'),
      HexColor('5d6bd4'),
    ];


    return preferred;
  }

  else
  {
    //Base colors from ColorScheme

    List<Color> baseColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.surface,
    ];

    // Generate additional colors by tweaking hue, saturation, and lightness
    List<Color> generatedColors = [];
    for (int i = 0; i < count; i++) {
      // Pick a base color to modify
      Color baseColor = baseColors[i % baseColors.length];
      HSLColor hslColor = HSLColor.fromColor(baseColor);

      // Adjust hue and lightness cyclically to generate variation
      double hue = (hslColor.hue + (i * 30)) % 360; // Rotate hue
      double lightness = (hslColor.lightness + (i % 2 == 0 ? 0.1 : -0.1))
          .clamp(0.2, 0.8); // Alternate brightness for contrast
      double saturation = hslColor.saturation.clamp(0.4, 1.0); // Ensure vividness

      // Add the modified color to the list
      generatedColors.add(
        HSLColor.fromAHSL(hslColor.alpha, hue, saturation, lightness).toColor(),
      );
    }

    return generatedColors;
  }



}

///Generate a Text Style regarding the color depending on the fillColor passed
TextStyle generateTextStyle(Color fillColor) {
  // Check brightness to decide contrasting text color
  bool isDark = ThemeData.estimateBrightnessForColor(fillColor) == Brightness.dark;
  Color textColor = isDark ? Colors.white : Colors.black;

  return TextStyle(
    color: textColor,
    fontFamily: AppCubit.language == 'ar' ? 'Cairo' : 'WithoutSans',
    fontSize: 12, // Adjust font size as needed
  );
}
