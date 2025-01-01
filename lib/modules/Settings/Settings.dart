import 'package:spinning_wheel/modules/Items/Items.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';

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
            child: OrientationBuilder(builder: (context,orientation)
            {
              if(orientation == Orientation.portrait)
              {
                return CustomScrollView(
                  slivers:
                  [
                    SliverFillRemaining(
                      child: itemBuilder(cubit: cubit),
                    ),
                  ],
                );
              }
              else
              {
                return SingleChildScrollView(child: itemBuilder(cubit: cubit),);
              }
            }),
          );
        }
    );
  }

  Widget itemBuilder({required AppCubit cubit,})=>Column(
    children:
    [
      const SizedBox(height: 15,),

      Center(
        child: CircleAvatar(
          radius: 70,
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

    ],
  );
}

