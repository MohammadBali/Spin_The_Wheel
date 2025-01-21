import 'package:my_logger/models/filter.dart';
import 'package:my_logger/models/logger.dart';
import 'package:spinning_wheel/modules/Items/Items.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  List<String> listOfLanguages = ['ar','en'];

  String currentLanguage= AppCubit.language??='ar';

  String currentColorChoice = AppCubit.currentColorChoice??='manual';

  @override
  Widget build(BuildContext context)
  {
    return BlocConsumer<AppCubit,AppStates>(
        listener: (context,state){},
        builder:(context,state)
        {
          var cubit = AppCubit.get(context);

          return RefreshIndicator(
            onRefresh: ()async
            {
              cubit.getDatabase(cubit.database);
            },
            child: SingleChildScrollView(child: itemBuilder(cubit: cubit),),
          );
        }
    );
  }

  Widget itemBuilder({required AppCubit cubit, bool isPortrait=true})=>Column(
    children:
    [
      const SizedBox(height: 15,),

      Center(
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.transparent,
          child: Image(
            image: AssetImage('assets/images/personal/personal.png'),
          ),
        ),
      ),

      const SizedBox(height: 10,),

      Text(
        '${Localization.translate('welcome_back')}!',
        style: textStyleBuilder(),
      ),

      defaultDivider(),

      const SizedBox(height: 25,),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        [
          const Icon(Icons.language_outlined),

          const SizedBox(width: 5,),

          Text(
            Localization.translate('language_name_general_settings'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle:const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                      labelText: Localization.translate('language_name_general_settings'),
                    ),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        style: TextStyle(color: cubit.isDarkTheme? defaultDarkColor : defaultColor),
                        value: currentLanguage,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            debugPrint('Current Language is: $newValue');
                            currentLanguage = newValue!;
                            state.didChange(newValue);

                            CacheHelper.saveData(key: 'language', value: newValue).then((value){
                              cubit.changeLanguage(newValue);
                              Localization.load(Locale(newValue));

                            }).catchError((error)
                            {
                              debugPrint('ERROR WHILE SWITCHING LANGUAGES, ${error.toString()}');
                              if(context.mounted)
                              {
                                snackBarBuilder(message: error.toString(), context: context);
                              }
                            });
                          });
                        },
                        items: listOfLanguages.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Text(
                                  value == 'ar' ? Localization.translate('arabic') : Localization.translate('english'),
                                  style: TextStyle(fontFamily: AppCubit.language == 'ar'? 'Cairo' : null),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 25,),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        [
          const Icon(Icons.color_lens_outlined),

          const SizedBox(width: 5,),

          Text(
            Localization.translate('coloring_scheme'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorStyle:const TextStyle(color: Colors.redAccent, fontSize: 16.0),
                      labelText: Localization.translate('coloring_scheme'),
                    ),

                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        style: TextStyle(color: cubit.isDarkTheme? defaultDarkColor : defaultColor),
                        value: currentColorChoice,
                        isDense: true,
                        onChanged: (newValue) {
                          setState(() {
                            currentColorChoice = newValue!;
                            state.didChange(newValue);

                            CacheHelper.saveData(key: 'currentColorChoice', value: newValue).then((value){
                              cubit.setCurrentColorChoice(newValue);

                            }).catchError((error)
                            {
                              debugPrint('ERROR WHILE SWITCHING COLOR SCHEME, ${error.toString()}');
                              if(context.mounted)
                              {
                                snackBarBuilder(message: error.toString(), context: context);
                              }
                            });
                          });
                        },

                        items: cubit.colorChoices.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    Localization.translate(value),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontFamily: AppCubit.language == 'ar'? 'Cairo' : null),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 15,),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        [
          Icon(
              cubit.isDarkTheme
                  ?Icons.dark_mode_outlined
                  :Icons.light_mode_outlined
          ),

          const SizedBox(width: 5,),

          Text(
            Localization.translate('dark_mode'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          Switch(
            value: cubit.isDarkTheme,
            padding: EdgeInsets.zero,
            onChanged: (val)
            {
              cubit.changeTheme();
            },

          ),
        ],
      ),

      const SizedBox(height: 15,),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        [
          Icon(
              cubit.shuffleColors
                  ?Icons.shuffle_on_outlined
                  :Icons.shuffle_outlined
          ),

          const SizedBox(width: 5,),

          Text(
            Localization.translate('shuffle_color'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          Switch(
            value: cubit.shuffleColors,
            padding: EdgeInsets.zero,
            onChanged: (val)
            {
              cubit.changeShuffleColor();
            },

          ),
        ],
      ),

      const SizedBox(height: 15,),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        [
          Icon(Icons.list_outlined),

          const SizedBox(width: 5,),

          Text(
            Localization.translate('items'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          defaultButton(
            message: Localization.translate('edit_items'),
            type: ButtonType.text,
            onPressed: ()
            {
              navigateTo(context, AllItems());
            }
          ),
        ],
      ),

      const SizedBox(height: 15,),

      Row(
        children:
        [
          const Icon(
            Icons.file_present_outlined,
            size: 22,
          ),

          const SizedBox(width: 10,),

          Text(
            Localization.translate('export_log'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          defaultButton(
              message: Localization.translate('export_now'),
              type: ButtonType.text,
              onPressed: ()async
              {
                await _showLogDialog(context, cubit);
              }
          ),

        ],
      ),

      const SizedBox(height: 15,),

      Row(
        children:
        [
          const Icon(
            Icons.delete_forever_outlined,
            size: 22,
          ),

          const SizedBox(width: 10,),

          Text(
            Localization.translate('delete_logs'),
            style: textStyleBuilder(fontSize: 18),
          ),

          const Spacer(),

          defaultButton(
            message: Localization.translate('delete_now'),
            type: ButtonType.text,
            onPressed: ()
            {
              MyLogger.logs.deleteAll();
              snackBarBuilder(context:context, message: Localization.translate('success'));
            },
          ),
        ],
      ),

      const SizedBox(height: 15,),

      Center(
        child: defaultButton(
            message: Localization.translate('about'),
            type: ButtonType.outlined,
            onPressed: ()
            {
              _aboutDialog(context: context);
            }
        ),
      ),


    ],
  );

  ///Show the About Us Dialog
  void _aboutDialog({required BuildContext context,})
  {
    showDialog(
        context: context,
        builder: (dialogContext)
        {
          return Directionality(
            textDirection: appDirectionality(),
            child: defaultAlertDialog(
                context: dialogContext,
                title: Localization.translate('about'),
                content: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children:
                      [
                        Text(
                          Localization.translate('about_secondary'),
                          style: textStyleBuilder(),
                        ),

                        const SizedBox(height: 15,),

                        Text(
                          Localization.translate('mhd_bali'),
                          style: textStyleBuilder(color: currentColorScheme(context).secondary),
                        ),

                        const SizedBox(height: 15,),

                        Text(
                          Localization.translate('about_email'),
                          style: textStyleBuilder(color: currentColorScheme(context).tertiary),
                        ),
                      ],
                    ),
                ),
            ),
          );
        }
    );
  }

  ///Dialog to represents the time span drop list
  Future<void> _showLogDialog(BuildContext context, AppCubit cubit)
  async {
    return await showDialog(
        context: context,
        builder: (dialogContext)
        {
          return defaultAlertDialog(
            context: dialogContext,
            title: Localization.translate('export_log'),
            content: Directionality(
              textDirection: appDirectionality(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                    Text(Localization.translate('export_title'), style: textStyleBuilder(),),

                    const SizedBox(height: 15,),

                    logDialogItemBuilder(cubit: cubit, title: Localization.translate('log_this_hour'), filter: LogFilter.thisHour(), dialogContext: dialogContext),

                    const SizedBox(height: 15,),

                    logDialogItemBuilder(cubit: cubit, title: Localization.translate('log_last_day'), filter: LogFilter.last24Hours(),dialogContext: dialogContext),

                    const SizedBox(height: 15,),

                    logDialogItemBuilder(cubit: cubit, title: Localization.translate('log_today'), filter: LogFilter.today(),dialogContext: dialogContext),

                    const SizedBox(height: 15,),

                    logDialogItemBuilder(cubit: cubit, title: Localization.translate('log_last_week'), filter: LogFilter.week(),dialogContext: dialogContext),

                    const SizedBox(height: 15,),

                    logDialogItemBuilder(cubit: cubit, title: Localization.translate('log_all'), filter: LogFilter.all(),dialogContext: dialogContext),

                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  ///Time Span Item Builder
  Widget logDialogItemBuilder({required AppCubit cubit, required BuildContext dialogContext, required String title, required LogFilter filter})
  {

    return Row(
      children: [
        Expanded(
          child: defaultButton(
            type: ButtonType.outlined,
            message: Localization.translate(title),
            onPressed: ()
            {
              defaultLogExporter(filter: filter, context: context);
              Navigator.of(dialogContext).pop();
            }
          ),
        ),
      ],
    );

  }
}

