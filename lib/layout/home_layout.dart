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
            appBar: (orientation== Orientation.portrait && cubit.isTabBarShown ==true)
                ? AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title:  Text(
                    Localization.translate('appBar_title_home'),

                  ),
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
                      },
                  ),
                flexibleSpace: Stack(
                  children: [
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
                ),
                )
                : null,

            body: Stack(
              children: [
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

}
