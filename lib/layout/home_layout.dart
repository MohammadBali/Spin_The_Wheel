import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin
{
  late TabController tabController;
  var formKey=GlobalKey<FormState>();


  @override
  void initState()
  {
    super.initState();
    tabController = TabController(length: AppCubit.get(context).tabBarWidgets.length, vsync: this);
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

        if(state is AppGetDatabaseErrorState)
        {
          snackBarBuilder(context: context, message: state.message);
        }

        if(state is AppInsertDatabaseSuccessState)
        {
          snackBarBuilder(context: context, message: Localization.translate('success'));
        }

        if(state is AppUpdateDatabaseSuccessState)
        {
          snackBarBuilder(context: context, message: Localization.translate('updated'));
        }
      },
      builder: (context,state)
      {
        var cubit = AppCubit.get(context);
        return Directionality(
          textDirection: appDirectionality(),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title:  Text(Localization.translate('appBar_title_home')),

              bottom: defaultTabBar(
                  context: context,
                  controller: tabController,
                  isPrimary: true,
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
                  ]
              ),
            ),

            body: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 18.0, vertical: 30.0),
              child: cubit.tabBarWidgets[cubit.tabBarIndex],
            ),
          ),
        );
      },

    );
  }
}
