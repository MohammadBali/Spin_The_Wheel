import 'package:flutter/material.dart';
import 'package:spinning_wheel/layout/cubit/cubit.dart';

import 'colors.dart';
//Refer to: https://docs.flutter.dev/release/breaking-changes/theme-data-accent-properties
//Refer to: https://github.com/flutter/flutter/issues/91605

///Setup the Light Theme Preferences
ThemeData lightTheme(context) => ThemeData(
  useMaterial3: true,

  colorScheme: lightColorScheme, // Use the light color scheme from colors.dart

  // Adjust properties based on Material 3 API changes and your theme preferences

  appBarTheme: AppBarTheme(
    titleSpacing: 16.0,
    elevation: 0.0,
    surfaceTintColor: Colors.transparent, // Recommended for Material 3
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: AppCubit.language == 'ar' ? 'Cairo' : null,
      fontSize: 20.0,
      color: lightColorScheme.onSurfaceVariant,
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: lightColorScheme.primary,
    elevation: 20,
    backgroundColor: lightColorScheme.surface,
  ),

  datePickerTheme: DatePickerThemeData(
    backgroundColor: lightColorScheme.surfaceContainerHigh,
    headerForegroundColor: lightColorScheme.onSurface,
    elevation: 4,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: lightColorScheme.primary,
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: lightColorScheme.inversePrimary,
    foregroundColor: Colors.white, // Element inside Color
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(lightColorScheme.surfaceContainerLow),
      foregroundColor: WidgetStateProperty.all(lightColorScheme.primary),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: lightColorScheme.onSurfaceVariant,
    suffixIconColor: lightColorScheme.onSurfaceVariant,

    labelStyle: TextStyle(
        color: lightColorScheme.onSurfaceVariant
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: lightColorScheme.surfaceContainerHighest),
    ),



  ),

  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(
      color: lightColorScheme.onSurface,

    ),

    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(lightColorScheme.surfaceContainer),
      shadowColor: WidgetStateProperty.all(lightColorScheme.shadow),
    ),

    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: lightColorScheme.onSurfaceVariant,
      suffixIconColor: lightColorScheme.onSurfaceVariant,

    ),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: lightColorScheme.surface,
    modalBackgroundColor: Colors.white,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: lightColorScheme.surface,
    indicatorColor: Colors.white,
  ),

  searchBarTheme: SearchBarThemeData(
    padding: WidgetStateProperty.all(const EdgeInsetsDirectional.symmetric(horizontal: 16)),
  ),

  textTheme: Theme.of(context).textTheme.apply(
    fontFamily: AppCubit.language == 'ar' ? 'Cairo' : null,
    bodyColor: lightColorScheme.onSurface, // Use onSurface for text
  ),

  // switchTheme: SwitchThemeData(
  //   thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
  //     if (states.contains(MaterialState.selected)) {
  //       return Colors.white;
  //     }
  //     if (states.contains(MaterialState.disabled)) {
  //       return Colors.white;
  //     }
  //     return lightColorScheme.primary;
  //   }),
  //   trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
  //     if (states.contains(MaterialState.selected)) {
  //       return Colors.white;
  //     }
  //     if (states.contains(MaterialState.disabled)) {
  //       return Colors.white;
  //     }
  //     return lightColorScheme.surfaceVariant; // Use surfaceVariant for track color
  //   }),
  // ),
);

///Setup the Dark Theme Preferences
ThemeData darkTheme(context) => ThemeData(
  useMaterial3: true,

  colorScheme: darkColorScheme,

  appBarTheme: AppBarTheme(
    titleSpacing: 16.0,
    elevation: 0.0,
    surfaceTintColor: Colors.transparent, // Recommended for Material 3
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.normal,
      fontFamily: AppCubit.language == 'ar' ? 'Cairo' : null,
      fontSize: 20.0,
      color: darkColorScheme.onSurfaceVariant,
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: darkColorScheme.primary,
    elevation: 20,
    backgroundColor: darkColorScheme.surface,
  ),

  datePickerTheme: DatePickerThemeData(
    backgroundColor: darkColorScheme.surfaceContainerHigh,
    headerForegroundColor: darkColorScheme.onSurface,
    elevation: 4,
  ),

  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: darkColorScheme.primary,
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: darkColorScheme.inversePrimary,
    foregroundColor: Colors.white, // Element inside Color
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(darkColorScheme.surfaceContainerLow),
      foregroundColor: WidgetStateProperty.all(darkColorScheme.primary),

    ),
  ),


  inputDecorationTheme: InputDecorationTheme(
    prefixIconColor: darkColorScheme.onSurfaceVariant,
    suffixIconColor: darkColorScheme.onSurfaceVariant,

    labelStyle: TextStyle(
        color: darkColorScheme.onSurfaceVariant
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: darkColorScheme.surfaceContainerHighest),
    ),



  ),

  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(
      color: darkColorScheme.onSurface,

    ),

    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(darkColorScheme.surfaceContainer),
      shadowColor: WidgetStateProperty.all(darkColorScheme.shadow),
    ),

    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: darkColorScheme.onSurfaceVariant,
      suffixIconColor: darkColorScheme.onSurfaceVariant,

    ),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: darkColorScheme.surface,
    modalBackgroundColor: Colors.white,
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: darkColorScheme.surface,
    indicatorColor: Colors.white,
  ),

  searchBarTheme: SearchBarThemeData(
    padding: WidgetStateProperty.all(const EdgeInsetsDirectional.symmetric(horizontal: 16)),
  ),


  textTheme: Theme.of(context).textTheme.apply(
    fontFamily: AppCubit.language == 'ar' ? 'Cairo' : null,
    bodyColor: darkColorScheme.onSurface,
  ),

  // switchTheme: SwitchThemeData(
  //   thumbColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
  //     if (states.contains(MaterialState.selected)) {
  //       return Colors.white;
  //     }
  //     if (states.contains(MaterialState.disabled)) {
  //       return Colors.white;
  //     }
  //     return darkColorScheme.primary;
  //   }),
  //   trackColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
  //     if (states.contains(MaterialState.selected)) {
  //       return Colors.white;
  //     }
  //     if (states.contains(MaterialState.disabled)) {
  //       return Colors.white;
  //     }
  //     return darkColorScheme.surfaceVariant; // Use surfaceVariant for track color
  //   }),
  // ),
);