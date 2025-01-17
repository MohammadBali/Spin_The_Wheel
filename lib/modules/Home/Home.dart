import 'dart:async';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:my_logger/core/constants.dart';
import 'package:soundpool/soundpool.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final StreamController<int> _controller = StreamController<int>.broadcast();

  Stream<int> get myStream => _controller.stream;
  bool _isSpinning = false; // Track spinning state

  late Soundpool pool;

  late int spinId;
  late int spinStream;

  late int winId;
  late int winStream;

  late int looseId;
  late int looseStream;

  bool _isPlaying = false;

  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;
  late ConfettiController _controllerCenter;


  ///Set Audio Assets
  void preloadAudio() async {
    spinId = await rootBundle.load('assets/audio/wheel.mp3').then((soundData)=> pool.load(soundData));
    winId = await rootBundle.load('assets/audio/clapping.mp3').then((soundData)=> pool.load(soundData));
    looseId = await rootBundle.load('assets/audio/loose.mp3').then((soundData)=> pool.load(soundData));
  }

  @override
  void initState() {
    super.initState();

    pool = Soundpool.fromOptions(options: SoundpoolOptions(streamType: StreamType.music));

    preloadAudio();

    _controllerCenterRight =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterLeft =
        ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));

    setState(() {
      AppCubit.get(context).setWheelColors();
    });
  }

  @override
  void dispose() {
    _controller.close();

    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerCenter.dispose();

    pool.dispose();

    super.dispose();
  }

  ///Triggers tha Spinning Action
  void spinWheel({required AppCubit cubit})
  {
    if (!_isPlaying)
    {
      try
      {
        playWheelSound(); // Start the sound when the wheel starts spinning

        cubit.changeIsDimmed();

        setState(()
        {
          _isSpinning = true; // Activate dimming
        });
        
        _controller.add(cubit.getDependentRandomIndex());
      }

      catch(error,stackTrace)
      {
        logData(
          data: 'ERROR WHILE SPINNING WHEEL..., ${error.toString()}',
          level: LogLevel.ERROR,
          exception: error,
          stacktrace: stackTrace,
          methodName: 'spinWheel',
        );
      }
    }
  }

  ///Start Spinning Sound
  void playWheelSound() async {
    if (!_isPlaying)
    {
      spinStream = await pool.play(spinId);

      setState(() {
        _isPlaying = true;
      });
    }
  }

  ///Stop Spinning Sound
  void stopWheelSound() async {
    if (_isPlaying) {

      await pool.stop(spinStream);

      setState(() {
        _isPlaying = false;
        _isSpinning = false; // Remove dimming
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {
        if (state is AppSpinWheelNoMoreAttemptsState) {
          snackBarBuilder(
              context: context,
              message: Localization.translate('no_more_spins'));
        }
      },

      builder: (context, state) {
        var cubit = AppCubit.get(context);

        return OrientationBuilder(
            builder: (context, orientation) => ConditionalBuilder(
                  condition: cubit.items != null && cubit.items!.items!.isNotEmpty,

                  builder: (context)
                  {
                    if(orientation == Orientation.portrait)
                    {
                      return SafeArea(
                        child: Column(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                cubit.isDimmed ? dimColor.withOpacity(dimValue) : Colors.transparent,
                                BlendMode.srcATop,
                              ),

                              child: GestureDetector(
                                child: AnimatedTextKit(
                                  isRepeatingAnimation: true,
                                  repeatForever: true,
                                  animatedTexts:
                                  [
                                    ColorizeAnimatedText(
                                      Localization.translate('home_title'),
                                      textStyle: TextStyle(
                                        fontSize: orientation == Orientation.portrait
                                            ? Theme.of(context).textTheme.displayLarge!.fontSize!
                                            : Theme.of(context).textTheme.displayMedium!.fontSize!,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Vidaloka',
                                        letterSpacing: 8,
                                      ),
                                      colors: cubit.isDimmed?
                                      [
                                        HexColor('FFFFFF').withOpacity(0.9),
                                        HexColor('F2E7F2').withOpacity(0.9),
                                        HexColor('E6CEE5').withOpacity(0.9),
                                        HexColor('D9B6D8').withOpacity(0.9),
                                        HexColor('CC9ECB').withOpacity(0.9),
                                        HexColor('C085BE').withOpacity(0.9),
                                        HexColor('B36DB1').withOpacity(0.9),
                                      ]:
                                      [
                                        HexColor('FFFFFF'),
                                        HexColor('F2E7F2'),
                                        HexColor('E6CEE5'),
                                        HexColor('D9B6D8'),
                                        HexColor('CC9ECB'),
                                        HexColor('C085BE'),
                                        HexColor('B36DB1'),
                                      ],
                                      speed: Duration(seconds: 3),
                                    ),
                                  ],

                                ),

                                onDoubleTap: () {
                                  cubit.changeIsTabBarShown();
                                },
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              Localization.translate('spin_win'),
                              style: headlineStyleBuilder(
                                fontSize: 26,

                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Expanded(
                              child: Center(
                                child: myWheel(cubit: cubit),
                              ),
                            ),

                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                cubit.isDimmed ? dimColor.withOpacity(dimValue) : Colors.transparent,
                                BlendMode.srcATop,
                              ),

                              child: AnimatedTextKit(
                                  isRepeatingAnimation: true,
                                  repeatForever: true,
                                  animatedTexts: [
                                    // TypewriterAnimatedText(
                                    //
                                    //   speed: Duration(milliseconds: 100),
                                    //   Localization.translate('home_secondary'),
                                    //   textStyle: headlineStyleBuilder(
                                    //       fontSize: orientation == Orientation.portrait
                                    //           ? Theme.of(context).textTheme.headlineMedium!.fontSize!
                                    //           : Theme.of(context).textTheme.headlineSmall!.fontSize!,
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'WithoutSans',
                                    //       color: currentColorScheme(context).primary
                                    //   ),
                                    // ),

                                    ColorizeAnimatedText(
                                      Localization.translate('home_secondary'),
                                      textStyle: headlineStyleBuilder(
                                        fontSize: orientation == Orientation.portrait
                                            ? Theme.of(context).textTheme.headlineMedium!.fontSize!
                                            : Theme.of(context).textTheme.headlineSmall!.fontSize!,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'WithoutSans',
                                      ),
                                      colors: cubit.isDimmed?
                                      [
                                        HexColor('E6CEE5').withOpacity(0.9),
                                        HexColor('D9B6D8').withOpacity(0.9),
                                        HexColor('CC9ECB').withOpacity(0.9),
                                        HexColor('C085BE').withOpacity(0.9),
                                        HexColor('B36DB1').withOpacity(0.9),
                                        HexColor('FFFFFF').withOpacity(0.9),
                                        HexColor('F2E7F2').withOpacity(0.9),

                                      ]:
                                      [
                                        HexColor('E6CEE5'),
                                        HexColor('D9B6D8'),
                                        HexColor('CC9ECB'),
                                        HexColor('C085BE'),
                                        HexColor('B36DB1'),
                                        HexColor('FFFFFF'),
                                        HexColor('F2E7F2'),
                                      ],
                                      speed: Duration(milliseconds: 1000),
                                    ),
                                  ]
                              ),
                            ),

                            if (orientation == Orientation.portrait &&
                                cubit.shuffleColors == true)
                              const SizedBox(
                                height: 40,
                              ),


                            //const Spacer(),

                            // defaultButton(
                            //   type: ButtonType.elevated,
                            //   onPressed: (){spinWheel(cubit: cubit);},
                            //   message: Localization.translate('spin'),
                            // ),
                          ],
                        ),
                      );
                    }

                    else
                    {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              cubit.isDimmed ? dimColor.withOpacity(dimValue) : Colors.transparent,
                              BlendMode.srcATop,
                            ),

                            child: GestureDetector(
                              child: AnimatedTextKit(
                                isRepeatingAnimation: true,
                                repeatForever: true,
                                animatedTexts:
                                [
                                  ColorizeAnimatedText(
                                    Localization.translate('home_title'),
                                    textStyle: TextStyle(
                                      fontSize: orientation == Orientation.portrait
                                          ? Theme.of(context).textTheme.displayLarge!.fontSize!
                                          : Theme.of(context).textTheme.displayMedium!.fontSize!,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Vidaloka',
                                      letterSpacing: 8,
                                    ),
                                    colors: cubit.isDimmed?
                                    [
                                      HexColor('FFFFFF').withOpacity(0.9),
                                      HexColor('F2E7F2').withOpacity(0.9),
                                      HexColor('E6CEE5').withOpacity(0.9),
                                      HexColor('D9B6D8').withOpacity(0.9),
                                      HexColor('CC9ECB').withOpacity(0.9),
                                      HexColor('C085BE').withOpacity(0.9),
                                      HexColor('B36DB1').withOpacity(0.9),
                                    ]:
                                    [
                                      HexColor('FFFFFF'),
                                      HexColor('F2E7F2'),
                                      HexColor('E6CEE5'),
                                      HexColor('D9B6D8'),
                                      HexColor('CC9ECB'),
                                      HexColor('C085BE'),
                                      HexColor('B36DB1'),
                                    ],
                                    speed: Duration(seconds: 3),
                                  ),
                                ],

                              ),

                              onDoubleTap: () {
                                cubit.changeIsTabBarShown();
                              },
                            ),
                          ),

                          Expanded(
                            child: Center(
                              child: myWheel(cubit: cubit),
                            ),
                          ),

                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              cubit.isDimmed ? dimColor.withOpacity(dimValue) : Colors.transparent,
                              BlendMode.srcATop,
                            ),

                            child: AnimatedTextKit(
                                isRepeatingAnimation: true,
                                repeatForever: true,
                                animatedTexts: [

                                  ColorizeAnimatedText(
                                    Localization.translate('home_secondary_two_lines'),
                                    textStyle: headlineStyleBuilder(
                                      fontSize: orientation == Orientation.portrait
                                          ? Theme.of(context).textTheme.headlineMedium!.fontSize!
                                          : Theme.of(context).textTheme.headlineSmall!.fontSize!,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'WithoutSans',
                                    ),
                                    colors: cubit.isDimmed?
                                    [
                                      HexColor('E6CEE5').withOpacity(0.9),
                                      HexColor('D9B6D8').withOpacity(0.9),
                                      HexColor('CC9ECB').withOpacity(0.9),
                                      HexColor('C085BE').withOpacity(0.9),
                                      HexColor('B36DB1').withOpacity(0.9),
                                      HexColor('FFFFFF').withOpacity(0.9),
                                      HexColor('F2E7F2').withOpacity(0.9),

                                    ]:
                                    [
                                      HexColor('E6CEE5'),
                                      HexColor('D9B6D8'),
                                      HexColor('CC9ECB'),
                                      HexColor('C085BE'),
                                      HexColor('B36DB1'),
                                      HexColor('FFFFFF'),
                                      HexColor('F2E7F2'),
                                    ],
                                    speed: Duration(milliseconds: 1000),
                                  ),
                                ]
                            ),
                          ),

                          // defaultButton(
                          //   type: ButtonType.elevated,
                          //   onPressed: (){spinWheel(cubit: cubit);},
                          //   message: Localization.translate('spin'),
                          // ),
                        ],
                      );
                    }
                  },

                  fallback: (context) =>
                      Center(child: defaultProgressIndicator(context: context)),
                )
        );
      },
    );
  }

  ///Wheel Settings
 Widget myWheel({required AppCubit cubit,})
  {
    return LayoutBuilder(builder: (context, constraints) {
      double maxSize = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints
              .maxHeight; // Take the smaller dimension for responsiveness

      // Calculate sizes dynamically based on available space
      double wheelSize = maxSize * 0.9; // 90% of the available width
      double borderSize = wheelSize * 1.06; // Border image slightly larger than the wheel  was wheelSize * 1.3

      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: borderSize,
            height: borderSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.pinkAccent,
                  Colors.orangeAccent,
                  Colors.yellow,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [
                  0.2,
                  0.5,
                  0.8,
                  1.0
                ], // Adjust color stops for smoother transition
              ),
            ),
          ),

          SizedBox(
            width: wheelSize,
            height: wheelSize,
            child: FortuneWheel(
              selected: myStream,
              duration: Duration(seconds: 6),
              onAnimationStart: () {
                playWheelSound();
              },
              onAnimationEnd: () {
                stopWheelSound();

                _dialog(context: context, cubit: cubit);

                cubit.changeIsDimmed();
              },
              onFling: ()
              {
                spinWheel(cubit: cubit);
              },
              animateFirst: false,
              styleStrategy: AlternatingStyleStrategy(),
              onFocusItemChanged: (index) {
                // print(cubit.items?.items?[index].label);
              },
              items: cubit.items!.items!.asMap().entries.map((element)
              {
                  int index = element.key; // Get the index
                  var choice = element.value; // Get the item

                  // Select color based on index
                  Color fillColor = AppCubit.currentColorChoice == 'manual'
                      ? choice.color!
                      : cubit.wheelColors[index % cubit.wheelColors.length];

                  return FortuneItem(
                    child: Text(
                      choice.label!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: AppCubit.language == 'ar'
                              ? FontWeight.w600
                              : null,
                          fontFamily: AppCubit.language == 'ar'
                              ? 'Cairo'
                              : 'WithoutSans'),
                    ),
                    style: FortuneItemStyle(
                        color: fillColor,
                        textStyle: generateTextStyle(fillColor),
                        borderWidth: cubit.isDarkTheme ? 2.5 : 2.5, // 2 : 3
                        borderColor: Colors.black),
                  );
                },
              ).toList(),
              hapticImpact: HapticImpact.heavy,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              createParticlePath: drawStar, // define a custom shape/path.
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _controllerCenterLeft,
              blastDirection: 0,
              // radial value - RIGHT
              emissionFrequency: 0.6,
              // set the minimum potential size for the confetti (width, height)
              minimumSize: const Size(10, 10),
              // set the maximum potential size for the confetti (width, height)
              maximumSize: const Size(50, 50),
              numberOfParticles: 1,
              gravity: 0.1,
              shouldLoop: false,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _controllerCenterRight,
              blastDirection: pi,
              // radial value - LEFT
              particleDrag: 0.05,
              // apply drag to the confetti
              emissionFrequency: 0.05,
              // how often it should emit
              numberOfParticles: 20,
              // number of particles to emit
              gravity: 0.05,
              // gravity - or fall speed
              shouldLoop: false,
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),

        ],
      );
    });
  }

  ///Show Dialog with the result
  void _dialog({required BuildContext context, required AppCubit cubit}) {
    if (cubit.currentItem != null) {
      _resultSound(cubit.currentItem!.type!);

      showDialog(
        context: context,
        builder: (dialogContext) {
          return defaultAlertDialog(
            context: dialogContext,
            title: cubit.currentItem?.type == ItemType.win
                ? Localization.translate('result_title_winning')
                : cubit.currentItem?.type == ItemType.loose
                    ? Localization.translate('result_title_loose')
                    : Localization.translate('result_title_tie'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Localization.translate('spin_result'),
                    style: textStyleBuilder(),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    cubit.currentItem?.label ?? '',
                    style: textStyleBuilder(
                        fontWeight: FontWeight.w600, fontSize: 24),
                  ),
                ],
              ),
            ),
            titleStyle:
                headlineStyleBuilder(fontWeight: FontWeight.w600, fontSize: 22),
          );
        },
      ).then((_) {
        // Dialog dismissed callback
        _controllerCenterLeft.stop();
        _controllerCenterRight.stop();
        _controllerCenter.stop();
      });
    } else {
      snackBarBuilder(
          context: context,
          message:
              '${Localization.translate('result')} ${cubit.currentItem?.label}');
    }
  }

  ///Choose Which Audio to Play With the Dialog
  void _resultSound(ItemType type) {
    switch (type) {
      case ItemType.win:
        _controllerCenterLeft.play();
        _controllerCenterRight.play();
        _controllerCenter.play();

        pool.play(winId);

        break;

      case ItemType.loose:
        pool.play(looseId);

        break;

      case ItemType.tie:
        break;
    }
  }
}
