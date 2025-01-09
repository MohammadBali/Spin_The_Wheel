// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:spinning_wheel/layout/cubit/cubit.dart';
import 'package:spinning_wheel/layout/cubit/states.dart';

void main() {

  late AppCubit appCubit;

  setUp(() {
    appCubit = AppCubit();

    // Initialize FFI
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
  });

  tearDown(() {
    appCubit.close();
  });

  group('AppCubit Theme Tests', ()
  {
    blocTest<AppCubit, AppStates>(
      'emits [AppChangeThemeModeState] when theme is toggled',
      build: () => appCubit,
      act: (cubit) => cubit.changeTheme(),
      expect: () => [isA<AppChangeThemeModeState>()],
      verify: (_) {
        expect(appCubit.isDarkTheme, true); // Check the toggled value
      },
    );

    blocTest<AppCubit, AppStates>(
      'loads theme from cache and emits [AppChangeThemeModeState]',
      build: () => appCubit,
      act: (cubit) => cubit.changeTheme(themeFromState: true),
      expect: () => [isA<AppChangeThemeModeState>()],
      verify: (_) {
        expect(appCubit.isDarkTheme, true);
      },
    );
  });

  group('AppCubit Tab Bar Tests', () {
    blocTest<AppCubit, AppStates>(
      'emits [AppChangeTabBar] when tab index changes',
      build: () => appCubit,
      act: (cubit) => cubit.changeTabBar(1),
      expect: () => [isA<AppChangeTabBar>()],
      verify: (_) {
        expect(appCubit.tabBarIndex, 1); // Check the updated index
      },
    );
  });

  group('AppCubit Language Change Tests', () {
    blocTest<AppCubit, AppStates>(
      'emits [AppChangeLanguageState] when language is changed',
      build: () => appCubit,
      act: (cubit) => cubit.changeLanguage('en'),
      expect: () => [isA<AppChangeLanguageState>()],
      verify: (_) {
        expect(AppCubit.language, 'en'); // Ensure language is updated
      },
    );
  });



}
