import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:spinning_wheel/layout/home_layout.dart';
import 'package:spinning_wheel/shared/bloc_observer.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/styles/themes.dart';

Future<void> main() async
{

  WidgetsFlutterBinding.ensureInitialized();

  //Initializing CacheHelper (SharedPreferences)
  await CacheHelper.init();

  //Load Language using Localization
  AppCubit.language= CacheHelper.getData(key: 'language');
  AppCubit.language ??= 'ar';


  AppCubit.currentColorChoice = CacheHelper.getData(key: 'currentColorChoice');
  AppCubit.currentColorChoice??='rainbow_choices';

  // Set the Initial Local; Language
  await Localization.load(Locale(AppCubit.language!));

  //print errors in console
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  //Bloc Observer; prints state changes & errors into console
  Bloc.observer = MyBlocObserver();

  //Getting the last Cached ThemeMode
  bool? isDark = CacheHelper.getData(key: 'isDarkTheme');
  isDark ??= true;


  runApp(MyApp(isDark: isDark, homeWidget: HomeLayout(),));
}

class MyApp extends StatelessWidget
{
  final bool isDark;
  final Widget homeWidget;  // Passing the widget to be loaded.

  const MyApp({super.key, required this.isDark, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    //Start the bloc provider which creates our BLoC
    return BlocProvider(
      create: (BuildContext context)=> AppCubit()..changeTheme(themeFromState: isDark)..createDatabase(),
      //Using Consumer to listen to any new changes and rebuild depending on that
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context,state){},
        builder: (context,state)=>MaterialApp(
          title: 'Spin The Wheel',
          theme: lightTheme(context),
          darkTheme: darkTheme(context),
          themeMode: AppCubit.get(context).isDarkTheme
              ? ThemeMode.dark
              : ThemeMode.light,
          home: Directionality(
            textDirection: appDirectionality(),
            //Animated Splash Screen to show logo on startup
            child: AnimatedSplashScreen(
              duration: 2000,
              animationDuration: const Duration(milliseconds: 200),
              splash:
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 14.0),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Image(
                        image: AssetImage(
                          'assets/images/splash/wheel.png',
                        ),
                        height: MediaQuery.of(context).size.height /2,
                        width: MediaQuery.of(context).size.width /2,
                      ),
                    ),

                    Center(
                      child: Text(
                        Localization.translate('spin_win'),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppCubit.language == 'en' ? 'WithoutSans' : 'Cairo',
                            color: AppCubit.get(context).isDarkTheme
                                ?darkColorScheme.secondary
                                :lightColorScheme.secondary
                        ),
                      ),
                    )
                  ],
                ),
              ),

              splashIconSize: MediaQuery.of(context).size.width /1.1,
              nextScreen: homeWidget,
              splashTransition: SplashTransition.fadeTransition,
              pageTransitionType: PageTransitionType.fade,
              backgroundColor:AppCubit.get(context).isDarkTheme? defaultHomeDarkColor : defaultHomeColor,
            ),
          ),
          debugShowCheckedModeBanner: false,

        ),
      ),
    );
  }
}