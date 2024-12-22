abstract class AppStates{}

class AppInitialState extends AppStates{}

class AppChangeTabBar extends AppStates{}

class AppChangeThemeModeState extends AppStates{}

class AppChangeLanguageState extends AppStates{}

class AppSetDefaultItems extends AppStates{}

//------------------------------------

//DB CREATION

class AppCreateDatabaseLoadingState extends AppStates{}

class AppCreateDatabaseErrorState extends AppStates{}

class AppCreateDatabaseSuccessState extends AppStates{}

//------------------------------------

//GET DB

class AppGetDatabaseLoadingState extends AppStates{}

class AppGetDatabaseSuccessState extends AppStates{}

class AppGetDatabaseErrorState extends AppStates{
  final String message;
  AppGetDatabaseErrorState({required this.message});
}

//INSERT TO DB

class AppInsertDatabaseLoadingState extends AppStates{}

class AppInsertDatabaseSuccessState extends AppStates{}

class AppInsertDatabaseErrorState extends AppStates{
  final String message;

  AppInsertDatabaseErrorState({required this.message});
}

//UPDATE DB

class AppUpdateDatabaseLoadingState extends AppStates{}

class AppUpdateDatabaseErrorState extends AppStates{
  final String message;

  AppUpdateDatabaseErrorState({required this.message});
}

class AppUpdateDatabaseSuccessState extends AppStates{}

//DELETE FROM DB

class AppDeleteFromDatabaseLoadingState extends AppStates{}

class AppDeleteFromDatabaseErrorState extends AppStates{
  final String message;

  AppDeleteFromDatabaseErrorState({required this.message});
}

class AppDeleteFromDatabaseSuccessState extends AppStates{}

//------------------------------------

//WHEEL SPIN

class AppSetCurrentItemState extends AppStates{}

class AppSpinWheelLoadingState extends AppStates{}

class AppSpinWheelSuccessState extends AppStates{}

class AppSpinWheelErrorState extends AppStates{
  final String message;

  AppSpinWheelErrorState({required this.message});
}

class AppSpinWheelNoMoreAttemptsState extends AppStates{}

//WHEEL COLORS

class AppChangeWheelColorsState extends AppStates{}

class AppSetShuffleColorState extends AppStates{}

class AppSetCurrentColorChoiceState extends AppStates{}

//------------------------------------

//ALTER ITEM

class AppAlterItemState extends AppStates{}

