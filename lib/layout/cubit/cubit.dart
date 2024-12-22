import 'dart:math';

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
    catch(e)
    {
      debugPrint('ERROR WHILE GETTING WEIGHTED RANDOM INDEX..., ${e.toString()}');

      emit(AppSpinWheelErrorState(message: 'ERROR WHILE GETTING WEIGHTED RANDOM INDEX..., ${e.toString()}'));
    }
    return -1;
  }

  ///Dependent Item Choosing
  ///It relies on the remaining attempts of each item
  int getDependentRandomIndex() {
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

          print('Printing Chosen Item..., ${item.toString()}');

          emit(AppSpinWheelSuccessState());
          setCurrentItem(i);
          return i;
        }
      }

      throw Exception("Failed to select an item based on weights.");
    } catch (e, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}');
      print(stackTrace);
      emit(AppSpinWheelErrorState(message: 'ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}'));
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


  ///Set The Colors Range for the Wheel
  void setWheelColors()
  {
    wheelColors = generateHarmoniousColors(
      currentColorScheme(),
      count: 12, // Generate 12 harmonious colors
    );

    wheelColors.shuffle();

    emit(AppChangeWheelColorsState());
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
            'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT, probability INTEGER, type TEXT, remainingAttempts INTEGER)'
        ).then((value)
        async {
          debugPrint('Table items has been created.');

          for (var item in defaultItems)
          {
            await database.transaction((txn) async {
              await txn
                  .rawInsert(
                  'INSERT INTO items(label, probability, type, remainingAttempts) VALUES("${item.label}", "${item.probability}", "${item.type?.name}", "${item.remainingAttempts}")')
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

    }).catchError((error)
    {
      debugPrint('ERROR WHILE CREATING DB..., ${error.toString()}');
      emit(AppCreateDatabaseErrorState());
    });
  }

  void getDatabase(Database? database)  {

    //items?.items= [];
    emit(AppGetDatabaseLoadingState());
    database?.rawQuery('SELECT * FROM items').then((value) async
    {
      items = ItemsModel.fromJson(value);
      emit(AppGetDatabaseSuccessState());
    }).catchError((error, stackTrace)
    {
      debugPrint('ERROR WHILE GETTING DATABASE..., ${error.toString()}');
      emit(AppGetDatabaseErrorState(message: 'ERROR WHILE GETTING DATABASE..., ${error.toString()}'));
    });
  }


  ///*Insert Into The Tasks Table
  ///[label] Item Label
  ///[probability] Occurring probability
  ///[type] It's ItemType, winning, loosing, etc...
  void insertIntoDatabase({
    required String label,
    required num probability,
    required ItemType type,
    required num remainingAttempts,
  }) async
  {
    emit(AppInsertDatabaseLoadingState());

    await database?.transaction((txn) async {
      await txn
          .rawInsert(
          'INSERT INTO items(label, probability, type, remainingAttempts) VALUES("$label", "$probability", "${type.name}", "$remainingAttempts")')
          .then((value) {
        debugPrint('$value has been Inserted successfully');
        emit(AppInsertDatabaseSuccessState());

        getDatabase(database!);

      }).catchError((error)
      {
        debugPrint('Error has occurred while inserting into database, ${error.toString()}');
        emit(AppInsertDatabaseErrorState(message: 'Error has occurred while inserting into database, ${error.toString()}'));
      });
    });
  }


//Todo:Set all occurring types
  void updateDatabase({ItemType? type, String? label, num? probability, num? remainingAttempts, required int id}) async
  {
    emit(AppUpdateDatabaseLoadingState());

    Map<String,dynamic> values={
      if(type !=null) 'type':type.name,
      if(label!=null) 'label':label,
      if(probability!=null) 'probability':probability,
      if(remainingAttempts!=null) 'remainingAttempts':remainingAttempts,
    };
    database!.update('items',values, where: 'id = ?', whereArgs: [id]).then((value)
    {
      getDatabase(database);
      emit(AppUpdateDatabaseSuccessState());
    }).catchError((error)
    {
      debugPrint('ERROR WHILE UPDATING DB..., ${error.toString()}');
      emit(AppUpdateDatabaseErrorState(message: 'ERROR WHILE UPDATING DB..., ${error.toString()}'));
    });
  }

  void deleteDatabase({required int id}) async
  {
    emit(AppDeleteFromDatabaseLoadingState());

    database!.rawDelete(
        'DELETE FROM items WHERE id = ?', [id]
    ).then((value)
    {
      getDatabase(database);
      emit(AppDeleteFromDatabaseSuccessState());
    }).catchError((error)
    {
      debugPrint('ERROR WHILE DELETING FROM DB..., ${error.toString()}');
      emit(AppDeleteFromDatabaseErrorState(message: 'ERROR WHILE DELETING FROM DB..., ${error.toString()}'));
    });
  }


  ///Sets The Default item Values
  void setDefaultItems()
  {
    items = ItemsModel.fromItems(defaultItems);
    emit(AppSetDefaultItems());
  }


  ///Alter an item
  void alterItem(ItemModel myItem)
  {
    updateDatabase(id: myItem.id!, label: myItem.label, type: myItem.type, probability: myItem.probability, remainingAttempts: myItem.remainingAttempts);

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
}