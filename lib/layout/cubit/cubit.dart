import 'dart:math';

import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/modules/Home/Home.dart';
import 'package:spinning_wheel/modules/Settings/Settings.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
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

  void setCurrentItem(int index)
  {
    currentItem = items!.items![index];

    emit(AppSetCurrentItemState());
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
            'CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, label TEXT, probability INTEGER, type TEXT)'
        ).then((value)
        async {
          debugPrint('Table items has been created.');

          for (var item in defaultItems)
          {
            await database.transaction((txn) async {
              await txn
                  .rawInsert(
                  'INSERT INTO items(label, probability, type) VALUES("${item.label}", "${item.probability}", "${item.type?.name}")')
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

    items?.items= [];
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
  }) async
  {
    emit(AppInsertDatabaseLoadingState());

    await database?.transaction((txn) async {
      await txn
          .rawInsert(
          'INSERT INTO items(label, probability, type) VALUES("$label", "$probability", "${type.name}")')
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
  void updateDatabase({ItemType? type, String? label, num? probability, required int id}) async
  {
    emit(AppUpdateDatabaseLoadingState());

    Map<String,dynamic> values={
      if(type !=null) 'type':type.name,
      if(label!=null) 'label':label,
      if(probability!=null) 'probability':probability
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
    updateDatabase(id: myItem.id!, label: myItem.label, type: myItem.type, probability: myItem.probability );

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