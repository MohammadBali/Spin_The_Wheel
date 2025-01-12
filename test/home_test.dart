import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinning_wheel/layout/cubit/cubit.dart';
import 'package:spinning_wheel/layout/cubit/states.dart';
import 'package:spinning_wheel/main.dart';
import 'package:spinning_wheel/layout/home_layout.dart';
import 'package:spinning_wheel/modules/Home/Home.dart';
import 'package:spinning_wheel/shared/bloc_observer.dart';
import 'package:spinning_wheel/shared/components/Localization/Localization.dart';
import 'package:spinning_wheel/shared/components/components.dart';
import 'package:spinning_wheel/shared/network/local/cache_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main()
{
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppCubit cubit;
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(()
  async {

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '/mocked/application/support/directory';
      }
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/mocked/application/documents/directory';
      }
      if (methodCall.method == 'getTemporaryDirectory') {
        return '/mocked/temporary/directory';
      }
      if (methodCall.method == 'getDownloadsDirectory') {
        return '/mocked/downloads/directory';
      }
      throw MissingPluginException();
    });

    WidgetsFlutterBinding.ensureInitialized();


    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    cubit = AppCubit();

    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();

    //Load Language using Localization
    AppCubit.language= CacheHelper.getData(key: 'language');
    AppCubit.language ??= 'ar';

    //Set The Color Scheme
    AppCubit.currentColorChoice = CacheHelper.getData(key: 'currentColorChoice');
    AppCubit.currentColorChoice??='manual';

    // Set the Initial Local; Language
    await Localization.load(Locale(AppCubit.language!));

    Bloc.observer = MyBlocObserver();


  });

  tearDown(()
  {
    cubit.close();
    channel.setMockMethodCallHandler(null);
  });

  group('main_home_test',()
  {
    testWidgets('home_no_items', (tester)async
    {

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: HomeLayout(),
        ),
        duration: Duration(seconds: 6),
      );

      // Use pump with a duration to let animations settle
      await tester.pump(const Duration(seconds: 6));

      expect(find.byType(Home), findsOneWidget);

      expect(cubit.items, isNull);

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });


    blocTest('createDB',
      build: ()=>cubit,
      act: (cubit)=>cubit.createDatabase(),
      expect: ()=>[
        isA<AppCreateDatabaseLoadingState>(),
        isA<AppGetDatabaseLoadingState>(),
        isA<AppCreateDatabaseSuccessState>(),
        isA<AppGetDatabaseSuccessState>(),
      ],
      wait: Duration(seconds: 3)
    );
  });
}