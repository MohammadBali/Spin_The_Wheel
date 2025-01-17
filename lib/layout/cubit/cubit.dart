import 'dart:math';

import 'package:my_logger/core/constants.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/modules/Home/Home.dart';
import 'package:spinning_wheel/modules/Settings/Settings.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';
import 'package:sqflite/sqflite.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit():super(AppInitialState());

  static AppCubit get(context)=> BlocProvider.of(context);

  ///DarkTheme Boolean
  bool isDarkTheme=false;

  ///Change Theme
  void changeTheme({bool? themeFromState})
  {
    if (themeFromState != null) //if a value is sent from main, then use it.. we didn't use CacheHelper because the value has already came from cache, then there is no need to..
        {
      isDarkTheme = themeFromState;
      emit(AppChangeThemeModeState());
    }

    else // else which means that the button of changing the theme has been pressed.
        {
      isDarkTheme = !isDarkTheme;
      CacheHelper.putBoolean(key: 'isDarkTheme', value: isDarkTheme).then((value) //Put the data in the sharedPref and then emit the change.
      {
        emit(AppChangeThemeModeState());
      });
    }
  }

  ///Returns current colorScheme
  ColorScheme currentColorScheme()
  {
    return isDarkTheme? darkColorScheme : lightColorScheme;
  }

  ///Current Language Code
  static String? language='en';

  ///Change Language
  void changeLanguage(String lang) async
  {
    language=lang;
    emit(AppChangeLanguageState());
  }

  //TAB BAR

  ///TabBar Current Index
  int tabBarIndex=0;

  ///Specify the tabBar Widgets
  List<Widget> tabBarWidgets=
  [
    Home(),
    Settings(),
  ];

  ///Alter the Current TabBar
  void changeTabBar(int index)
  {
    tabBarIndex = index;
    emit(AppChangeTabBar());
  }


  ///if the TabBar is Shown
  bool isTabBarShown = true;

  ///Sets if the TabBar is Shown
  void changeIsTabBarShown()
  {
    isTabBarShown = !isTabBarShown;

    emit(AppChangeTabBarShownState());
  }

  //--------------------------------------------------\\

  //DIM SCREEN LIGHT

  bool isDimmed=false;

  ///Change the [isDimmed] variable
  void changeIsDimmed()
  {
    isDimmed = !isDimmed;
    emit(AppChangeDimLightState());
  }

  //--------------------------------------------------\\

  //SPINNING WHEEL

  ItemModel? currentItem;

  int getWeightedRandomIndex()
  {
    try
    {
      emit(AppSpinWheelLoadingState());

      final random = Random();
      final randValue = random.nextDouble();
      double cumulativeProbability = 0.0;

      for (int i = 0; i < items!.items!.length ; i++) {
        cumulativeProbability += items!.items![i].probability!;
        if (randValue <= cumulativeProbability)
        {
          emit(AppSpinWheelSuccessState());
          setCurrentItem(i);
          return i;
        }
      }

      return items!.items!.length - 1; // Fallback in case of rounding errors
    }
    catch(e, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING WEIGHTED RANDOM INDEX..., ${e.toString()}');

      emit(AppSpinWheelErrorState(message: 'ERROR WHILE GETTING WEIGHTED RANDOM INDEX..., ${e.toString()}'));

      logData(
        data: 'ERROR WHILE GETTING WEIGHTED RANDOM INDEX..., ${e.toString()}',
        level: LogLevel.ERROR,
        exception: e,
        stacktrace: stackTrace,
        methodName: 'getWeightedRandomIndex',
      );
    }
    return -1;
  }

  ///Dependent Item Choosing
  ///It relies on the remaining attempts of each item
  int getDependentRandomIndex2() {
    try
    {
      emit(AppSpinWheelLoadingState());

      // Calculate the total remaining attempts
      int totalRemaining = items!.items!.fold(0, (sum, item) => sum + item.remainingAttempts!.toInt());

      //Reset the remaining attempts if total remaining is 0
      if (totalRemaining == 0)
      {
        emit(AppSpinWheelNoMoreAttemptsState());

        for (var item in items!.items!)
        {
          item.initializeRemainingAttempts();
          updateDatabase(id: item.id!, remainingAttempts: item.remainingAttempts);
        }

        totalRemaining = items!.items!.fold(0, (sum, item) => sum + item.remainingAttempts!.toInt());
      }

      // Random selection based on remaining attempts
      final random = Random();
      int randValue = random.nextInt(totalRemaining);
      int cumulativeWeight = 0;

      for (int i = 0; i < items!.items!.length; i++) {
        cumulativeWeight += items!.items![i].remainingAttempts!.toInt();
        if (randValue < cumulativeWeight)
        {
          ItemModel item = items!.items![i];

          // Update remaining attempts for the selected item
          item.remainingAttempts = (item.remainingAttempts!.toInt() - 1).clamp(0, totalRemaining);
          updateDatabase(id: item.id!, remainingAttempts: item.remainingAttempts);

          emit(AppSpinWheelSuccessState());
          setCurrentItem(i);

          logData(
            data: 'The Wheel Was Spent with item: ${item.toString()}',
            level: LogLevel.INFO,
            methodName: 'getDependentRandomIndex',
          );

          return i;
        }
      }

      throw Exception("Failed to select an item based on weights.");
    } catch (e, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}');

      emit(AppSpinWheelErrorState(message: 'ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}'));

      logData(
        data: 'ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}',
        level: LogLevel.ERROR,
        exception: e,
        stacktrace: stackTrace,
        methodName: 'getDependentRandomIndex',
      );
    }
    return -1;
  }


  ///Dependent Item Choosing, with scaling factor
  int getDependentRandomIndex() {
    try
    {
      emit(AppSpinWheelLoadingState());

      // Calculate the total remaining attempts
      double totalRemaining = items!.items!.fold(0, (sum, item) => sum + item.remainingAttempts!.toDouble());

      //Reset the remaining attempts if total remaining is 0
      if (totalRemaining == 0.0)
      {
        emit(AppSpinWheelNoMoreAttemptsState());

        for (var item in items!.items!)
        {
          item.initializeRemainingAttempts();
          updateDatabase(id: item.id!, remainingAttempts: item.remainingAttempts);
        }

        totalRemaining = items!.items!.fold(0, (sum, item) => sum + item.remainingAttempts!.toDouble());

        if (totalRemaining == 0.0) {
          throw Exception("No items with remaining attempts after reset.");
        }
      }

      //Scaling the items with weights so we can measure the fractions
      List<double> scaledWeights = items!.items!.map((item) => item.remainingAttempts!.toDouble() * scaleFactor).toList();

      // Calculate total weight for random selection
      double totalWeight = scaledWeights.reduce((a, b) => a + b);

      // Random selection based on remaining attempts
      final random = Random();
      double randValue = random.nextDouble() * totalWeight;
      double cumulativeWeight = 0.0;

      for (int i = 0; i < items!.items!.length; i++) {
        cumulativeWeight += scaledWeights[i];
        if (randValue < cumulativeWeight)
        {
          ItemModel item = items!.items![i];

          // Update remaining attempts for the selected item
          item.remainingAttempts = (item.remainingAttempts!.toDouble() - 1).clamp(0.0, totalRemaining);

          updateDatabase(id: item.id!, remainingAttempts: item.remainingAttempts);

          emit(AppSpinWheelSuccessState());
          setCurrentItem(i);

          logData(
            data: 'The Wheel Was Spent with item: ${item.toString()}',
            level: LogLevel.INFO,
            methodName: 'getDependentRandomIndex',
          );

          return i;
        }
      }

      throw Exception("Failed to select an item based on weights.");
    } catch (e, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}');

      emit(AppSpinWheelErrorState(message: 'ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}'));

      logData(
        data: 'ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}',
        level: LogLevel.ERROR,
        exception: e,
        stacktrace: stackTrace,
        methodName: 'getDependentRandomIndex',
      );
    }
    return -1;
  }

  void setCurrentItem(int index)
  {
    currentItem = items!.items![index];

    emit(AppSetCurrentItemState());
  }


  ///List of Colors
  late List<Color> wheelColors;

  ///Shuffle Colors?
  bool shuffleColors=false;

  ///Set The Colors Range for the Wheel
  void setWheelColors()
  {
    try
    {
      wheelColors = generateHarmoniousColors(
        currentColorScheme(),
        count: 12, // Generate 12 harmonious colors
        isRainbow: currentColorChoice != colorChoices[0]? false : true,
      );

      if(shuffleColors)
      {
        wheelColors.shuffle();
      }

      emit(AppChangeWheelColorsState());
    }
    catch(e,stackTrace)
    {
      debugPrint('ERROR WHILE CHANGING WHEEL COLORS..., ${e.toString()}');
      emit(AppChangeWheelColorsErrorState());

      logData(
        data: 'ERROR WHILE CHANGING WHEEL COLORS..., ${e.toString()}',
        level: LogLevel.ERROR,
        exception: e,
        stacktrace: stackTrace,
        methodName: 'setWheelColors',
      );
    }
  }

  ///Set Shuffle Colors
  void changeShuffleColor()
  {
    shuffleColors = !shuffleColors;
    emit(AppSetShuffleColorState());
  }

  ///List of Color Choices
  List<String> colorChoices=['rainbow_choices', 'color_scheme_choices', 'manual'];

  ///Current Color Choice
  ///[rainbow_choices] Colors are from the main 12 Colors
  ///[color_scheme_choices] Colors are derived from the current Mode; Light or Dark
  ///[manual] Colors that are assigned
  static String? currentColorChoice;

  ///Set The Choice
  void setCurrentColorChoice(String value)
  {
    colorChoices.contains(value)
      ?currentColorChoice = value
      :currentColorChoice = colorChoices[0];

    emit(AppSetCurrentColorChoiceState());
  }
  //--------------------------------------------------\\

  ///All Items
  ItemsModel? items;

  //DB MANAGEMENT

  Database? database;

  ///Creates The Database
  ///* If Already exists => Open it
  void createDatabase()
  {
    emit(AppCreateDatabaseLoadingState());

    openDatabase(
      'spin.db',
      version: 1,
      onCreate: (database, version) async
      {
        debugPrint('Database has been created...');
        await database.execute(
            'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT, probability INTEGER, type TEXT, remainingAttempts INTEGER, color TEXT)'
        ).then((value)
        async {
          debugPrint('Table items has been created.');

          for (var item in defaultItems)
          {
            await database.transaction((txn) async {
              await txn
                  .rawInsert(
                  'INSERT INTO items(label, probability, type, remainingAttempts, color) VALUES("${item.label}", "${item.probability}", "${item.type?.name}", "${item.remainingAttempts}", "${hexCodeExtractor(item.color!)}")')
                  .then((value) {
                debugPrint('$value has been Inserted successfully');
                emit(AppInsertDatabaseSuccessState());
              }).catchError((error)
              {
                debugPrint('Error has occurred while inserting into database, ${error.toString()}');
                emit(AppInsertDatabaseErrorState(message: 'Error has occurred while inserting into database, ${error.toString()}'));
              });
            });
          }

        }).catchError((error) {
          debugPrint('An error occurred when creating items table ${error.toString()}');
          emit(AppCreateDatabaseErrorState());
        });
      },
      onOpen: (database) {
        debugPrint('DB has been opened.');
        getDatabase(database);
      },

    ).then((value) {
      database = value;
      emit(AppCreateDatabaseSuccessState());

      logData(
        data: 'Created & Opened Database...',
        level: LogLevel.INFO,
        methodName: 'createDatabase',
      );

    }).catchError((e, stackTrace)
    {
      debugPrint('ERROR WHILE CREATING DB..., ${e.toString()}');
      emit(AppCreateDatabaseErrorState());

      logData(
        data: 'ERROR WHILE CREATING DB..., ${e.toString()}',
        level: LogLevel.ERROR,
        exception: e,
        stacktrace: stackTrace,
        methodName: 'createDatabase',
      );
    });
  }

  void getDatabase(Database? database)  {

    //items?.items= [];
    emit(AppGetDatabaseLoadingState());
    database?.rawQuery('SELECT * FROM items').then((value) async
    {
      items = ItemsModel.fromJson(value);
      emit(AppGetDatabaseSuccessState());

      logData(
        data: 'Got Database...',
        level: LogLevel.INFO,
        methodName: 'getDatabase',
      );

    }).catchError((error, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING DATABASE..., ${error.toString()}');
      debugPrint(stackTrace);
      emit(AppGetDatabaseErrorState(message: 'ERROR WHILE GETTING DATABASE..., ${error.toString()}'));

      logData(
        data: 'ERROR WHILE GETTING DATABASE..., ${error.toString()}',
        level: LogLevel.ERROR,
        exception: error,
        stacktrace: stackTrace,
        methodName: 'getDatabase',
      );
    });
  }

  ///* Insert Into The Tasks Table
  ///* [label] Item Label
  ///* [probability] Occurring probability
  ///* [type] It's ItemType, winning, loosing, etc...
  void insertIntoDatabase({
    required String label,
    required num probability,
    required ItemType type,
    required num remainingAttempts,
    required String color,
  }) async
  {
    emit(AppInsertDatabaseLoadingState());

    await database?.transaction((txn) async {
      await txn
          .rawInsert(
          'INSERT INTO items(label, probability, type, remainingAttempts, color) VALUES("$label", "$probability", "${type.name}", "$remainingAttempts", "$color")')
          .then((value) {
        debugPrint('$value has been Inserted successfully');
        emit(AppInsertDatabaseSuccessState());

        logData(
          data: 'Added to  Database The Item: '
              'label:$label / probability:$probability / remainingAttempts:$remainingAttempts'
              ' / color:$color / type:${type.name}',
          level: LogLevel.INFO,
          methodName: 'insertIntoDatabase',
        );

        getDatabase(database!);

      }).catchError((error, stackTrace)
      {
        debugPrint('ERROR WHILE INSERTING INTO DB..., ${error.toString()}');
        emit(AppInsertDatabaseErrorState(message: 'Error has occurred while inserting into database, ${error.toString()}'));

        logData(
          data: 'ERROR WHILE INSERTING INTO DB..., ${error.toString()}',
          level: LogLevel.ERROR,
          exception: error,
          stacktrace: stackTrace,
          methodName: 'insertIntoDatabase',
        );

      });
    });
  }

  ///* Update in Database
  ///* [id] required ID to update
  ///Provide any fields to be updated
  void updateDatabase({ItemType? type, String? label, num? probability, num? remainingAttempts, String? color, required int id, bool showSnack=false,}) async
  {
    emit(AppUpdateDatabaseLoadingState());

    Map<String,dynamic> values={
      if(type !=null) 'type':type.name,
      if(label!=null) 'label':label,
      if(probability!=null) 'probability':probability,
      if(remainingAttempts!=null) 'remainingAttempts':remainingAttempts,
      if(color!=null) 'color':color,
    };

    database!.update('items',values, where: 'id = ?', whereArgs: [id]).then((value)
    {
      getDatabase(database);
      emit(AppUpdateDatabaseSuccessState(showSnack: showSnack));

      logData(
        data: 'Updated Database with the following values: '
            'ItemType:${type?? type?.name} / label:$label / probability:$probability / remainingAttempts:$remainingAttempts'
            ' / color:$color / id:$id',
        level: LogLevel.INFO,
        methodName: 'updateDatabase',
      );
    }).catchError((error, stackTrace)
    {
      debugPrint('ERROR WHILE UPDATING DB..., ${error.toString()}');
      emit(AppUpdateDatabaseErrorState(message: 'ERROR WHILE UPDATING DB..., ${error.toString()}'));

      logData(
        data: 'ERROR WHILE UPDATING INTO DB..., ${error.toString()}',
        level: LogLevel.ERROR,
        exception: error,
        stacktrace: stackTrace,
        methodName: 'updateDatabase',
      );
    });
  }

  ///* Remove from Database
  ///* [id] required ID to delete
  void deleteFromDatabase({required int id}) async
  {
    emit(AppDeleteFromDatabaseLoadingState());

    database!.rawDelete(
        'DELETE FROM items WHERE id = ?', [id]
    ).then((value)
    {
      getDatabase(database);
      emit(AppDeleteFromDatabaseSuccessState());

      logData(
        data: 'Updated Database with the following: id:$id',
        level: LogLevel.INFO,
        methodName: 'deleteDatabase',
      );

    }).catchError((error, stackTrace)
    {
      debugPrint('ERROR WHILE DELETING FROM DB..., ${error.toString()}');
      emit(AppDeleteFromDatabaseErrorState(message: 'ERROR WHILE DELETING FROM DB..., ${error.toString()}'));

      logData(
        data: 'ERROR WHILE DELETING INTO DB..., ${error.toString()}',
        level: LogLevel.ERROR,
        exception: error,
        stacktrace: stackTrace,
        methodName: 'deleteDatabase',
      );
    });
  }


  ///Sets The Default item Values
  void setDefaultItems()
  {
    items = ItemsModel.fromItems(defaultItems);
    emit(AppSetDefaultItems());
  }


  ///Alter an item
  void alterItem(ItemModel myItem, {bool showSnack =false})
  {
    try
    {
      updateDatabase(
          id: myItem.id!, label: myItem.label, type: myItem.type,
          probability: myItem.probability, remainingAttempts: myItem.remainingAttempts,
          color: hexCodeExtractor(myItem.color!),
          showSnack: showSnack
      );

      for (var item in items?.items ?? [])
      {
        if(item.id == myItem.id)
        {
          item = myItem;
          emit(AppAlterItemState());
          break;
        }
      }
    }

    catch(error, stackTrace)
    {
      logData(
        data: 'ERROR WHILE ALTERING ITEM..., ${error.toString()}',
        level: LogLevel.ERROR,
        exception: error,
        stacktrace: stackTrace,
        methodName: 'alterItem',
      );
    }
  }
}