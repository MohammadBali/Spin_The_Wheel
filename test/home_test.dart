import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinning_wheel/layout/cubit/cubit.dart';
import 'package:spinning_wheel/layout/home_layout.dart';
import 'package:spinning_wheel/modules/Home/Home.dart';
import 'package:spinning_wheel/shared/bloc_observer.dart';
import 'package:spinning_wheel/shared/components/Localization/Localization.dart';
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
    cubit.createDatabase();

    await Future.delayed(const Duration(seconds: 2));

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
    //cubit.close();
    channel.setMockMethodCallHandler(null);
  });

  group('main_home_test',()
  {

    testWidgets('home_with_items', (tester)async
    {
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: HomeLayout(),
        ),
        duration: Duration(seconds: 6),
      );

      // Wait for the FutureBuilder to complete its Future and rebuild the UI
      //await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(Home), findsOneWidget);

      expect(cubit.items, isNotNull);

      expect(find.byType(FortuneWheel), findsWidgets);

      final index = cubit.getDependentRandomIndex();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(index, isA<int>());


    });

    testWidgets('home_no_items', (tester)async
    {
      cubit.items=null;

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


    // testWidgets('validate getDependentRandomIndex probabilities', (tester) async {
    //
    //   // Map to track appearances of each item
    //   Map<int, int> itemAppearances = {for (var item in cubit.items!.items!) item.id!: 0};
    //
    //   // Run 100 iterations of the method
    //   for (int i = 0; i < 100; i++)
    //   {
    //     final index = cubit.getDependentRandomIndex();
    //
    //     expect(index, isA<int>()); // Ensure the index is valid
    //
    //     itemAppearances[cubit.items!.items![index].id!] = itemAppearances[cubit.items!.items![index].id!]! + 1;
    //   }
    //
    //   // Verify the results
    //   for (var item in cubit.items!.items!) {
    //     final actualCount = itemAppearances[item.id]!;
    //     final expectedCount = (item.probability! * 100).round();
    //
    //     // Allow a small margin of error since this is probabilistic
    //     final margin = 5; // 5% margin
    //     expect(
    //       (actualCount - expectedCount).abs(),
    //       lessThanOrEqualTo(margin),
    //       reason: 'Item with id ${item.id} appeared $actualCount times, expected around $expectedCount',
    //     );
    //   }
    // });


    blocTest('createDB',
      build: ()=>cubit,
      act: (cubit)=>cubit.createDatabase(),
      verify: (cubit){
      expect(cubit.database, isNotNull);
      },
      wait: Duration(seconds: 3)
    );
  });
}