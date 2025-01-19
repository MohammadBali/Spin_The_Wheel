import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin
{
  late TabController tabController;
  TextEditingController passController = TextEditingController();
  var formKey=GlobalKey<FormState>();

  @override
  void initState()
  {
    super.initState();
    tabController = TabController(length: AppCubit.get(context).tabBarWidgets.length, vsync: this);
  }

  @override
  void dispose()
  {
    passController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state)
      {
        // if(state is AppGetDatabaseLoadingState)
        // {
        //   snackBarBuilder(context: context, message: Localization.translate('db_loading'));
        // }
        //
        // if(state is AppGetDatabaseSuccessState)
        // {
        //   snackBarBuilder(context: context, message: Localization.translate('db_success'));
        // }

        if(state is AppUpdateDatabaseSuccessState)
        {
          if(state.showSnack == true)
          {
            snackBarBuilder(context: context, message: Localization.translate('updated'));
          }
        }

        if(state is AppGetDatabaseErrorState)
        {
          snackBarBuilder(context: context, message: state.message);
        }

        if(state is AppInsertDatabaseSuccessState)
        {
          snackBarBuilder(context: context, message: Localization.translate('success'));
        }


      },

      builder: (context,state)
      {
        var cubit = AppCubit.get(context);
        return Directionality(
          textDirection: appDirectionality(),
          child: OrientationBuilder(builder: (context,orientation)=>Scaffold(
            backgroundColor: cubit.isDarkTheme? currentColorScheme(context).surface : currentColorScheme(context).primaryContainer,
            appBar: (orientation== Orientation.portrait && cubit.isTabBarShown ==true)
                ? AppBar(
                  title:  Text(
                    Localization.translate('appBar_title_home'),
                    style: TextStyle(
                        fontFamily: AppCubit.language == 'en'
                            ? 'WithoutSans'
                            : 'Cairo'
                    ),
                  ),
                  backgroundColor: cubit.isDarkTheme? currentColorScheme(context).surface : currentColorScheme(context).primaryContainer,
                  bottom: defaultTabBar(
                      context: context,
                      controller: tabController,
                      isPrimary: true,
                      dividerColor: Colors.transparent,
                      tabs:
                      [
                        Tab(
                          icon: const Icon(Icons.home_outlined),

                          text: Localization.translate('home'),
                        ),

                        Tab(
                          icon: const Icon(Icons.settings_outlined),
                          text: Localization.translate('settings'),
                        ),

                      ],

                      onTap: (index)
                      {
                        cubit.changeTabBar(index);
                        // if(cubit.tabBarIndex != index && index ==1)
                        // {
                        //   _showPasswordDialog(context, cubit, index);
                        // }
                        // else
                        // {
                        //   cubit.changeTabBar(index);
                        // }
                      },
                  ),
                  flexibleSpace: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              cubit.isDarkTheme
                                  ?'assets/images/background/chinese.png'
                                  :'assets/images/background/points.png',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.9,
                          ),
                        ),
                      ),

                      IgnorePointer(
                        ignoring: true,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          opacity: cubit.isDimmed ? dimValue : 0.0, // Control dim level
                          child: Container(
                            color: dimColor, // Dim overlay color
                          ),
                        ),
                      ),
                    ],
                  )
                )
                : null,

            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        cubit.isDarkTheme
                            ?'assets/images/background/chinese.png'
                            :'assets/images/background/points.png',
                      ),
                      fit: BoxFit.cover,
                      opacity: 0.9,
                    ),
                  ),
                ),

                // Animated Dimmer Overlay
                IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    opacity: cubit.isDimmed ? dimValue : 0.0, // Control dim level
                    child: Container(
                      color: dimColor, // Dim overlay color
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 18.0, vertical: 30.0),
                  child: cubit.tabBarWidgets[cubit.tabBarIndex],
                ),
              ],
            ),


            floatingActionButton: cubit.tabBarIndex==0 && cubit.shuffleColors==true
                ?FloatingActionButton(
              tooltip: 'Repaint',
              onPressed: ()
              {
                cubit.setWheelColors();
              },
              child: Icon(Icons.format_paint_outlined),
            )
                :null,
            //backgroundColor: darkColorScheme.primary,
          )),
        );
      },

    );
  }

  ///Prepare a Dialog to enter password, if correct => Head to Settings Page
  void _showPasswordDialog(BuildContext context, AppCubit cubit, int index)
  {
    showDialog(
      context: context,
      builder: (dialogContext)=>defaultAlertDialog(
        context: dialogContext,
        title: Localization.translate('enter_pass'),
        content: StatefulBuilder(
            builder: (dialogContext, setState)
            {
              return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children:
                      [
                        Directionality(
                          textDirection: appDirectionality(),
                          child: defaultTextFormField(
                            controller: passController,
                            keyboard: TextInputType.text,
                            label: Localization.translate('password_login_tfm'),
                            prefix: Icons.password_outlined,
                            isObscure: true,
                            contentPadding: 12,
                            validate: (value)
                            {
                              if(value!.isEmpty)
                              {
                                return Localization.translate('password_login_tfm_error');
                              }

                              if(value != settingsPassword)
                              {
                                return Localization.translate('login_error_toast');
                              }

                              return null;
                            },

                          ),
                        ),

                        const SizedBox(height: 15,),

                        Center(
                          child: defaultButton(
                              message: Localization.translate('submit_button'),
                              type: ButtonType.elevated,
                              onPressed: ()
                              {
                                if(formKey.currentState!.validate())
                                {
                                  passController.text='';

                                  Navigator.of(dialogContext).pop();
                                  cubit.changeTabBar(index);
                                }

                                else
                                {
                                  passController.text='';
                                }

                              }
                          ),
                        ),
                      ],
                    ),
                  )
              );
            }
        ),
      ),
      barrierDismissible: true,

    );
  }
}
