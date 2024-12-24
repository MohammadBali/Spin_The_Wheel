import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
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
  late AudioPlayer _audioPlayer;

  Timer? _speedTimer;
  bool _isPlaying = false;
  final double _currentPlaybackSpeed = 1.0;


  late ConfettiController _controllerCenterRight;
  late ConfettiController _controllerCenterLeft;
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _controllerCenterRight = ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenterLeft = ConfettiController(duration: const Duration(seconds: 10));
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 10));

    setState(() {
      AppCubit.get(context).setWheelColors();
    });
  }

  @override
  void dispose() {
    _controller.close();
    _audioPlayer.dispose();
    _speedTimer?.cancel();

    _controllerCenterRight.dispose();
    _controllerCenterLeft.dispose();
    _controllerCenter.dispose();
    super.dispose();
  }

  ///Triggers tha Spinning Action
  void spinWheel()
  {
    if(! _isPlaying)
    {
      setState(() {
        _isSpinning = true; // Activate dimming
      });

      playWheelSound(); // Start the sound when the wheel starts spinning
      _controller.add(AppCubit.get(context).getDependentRandomIndex());
    }
  }

  ///Start Spinning Sound
  void playWheelSound() async {
    if (!_isPlaying)
    {
      setState(()
      {
        _isPlaying = true;
      });

      // Loop the sound
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setPlaybackRate(_currentPlaybackSpeed);
      await _audioPlayer.play(AssetSource('audio/wheel.mp3'), volume: 1.0);

    }
  }

  ///Stop Spinning Sound
  void stopWheelSound() async {
    if (_isPlaying)
    {
      _speedTimer?.cancel();
      await _audioPlayer.stop();

      setState(() {
        _isPlaying = false;
        _isSpinning = false; // Remove dimming
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
        listener: (context,state)
        {
          if(state is AppSpinWheelNoMoreAttemptsState)
          {
            snackBarBuilder(context: context, message: Localization.translate('no_more_spins'));
          }
        },
        builder: (context,state)
        {
          var cubit = AppCubit.get(context);
          return ConditionalBuilder(
            condition: cubit.items !=null && cubit.items!.items!.isNotEmpty,
            builder: (context)=>SafeArea(
              child: Column(
                children:
                [
                  GestureDetector(
                    child: Text(
                      Localization.translate('spin_win'),
                      style: headlineStyleBuilder(fontSize: 24, fontWeight: FontWeight.w500, color: currentColorScheme(context).secondary),
                    ),
                    onDoubleTap: ()
                    {
                      cubit.changeIsTabBarShown();
                    },
                  ),

                  const SizedBox(height: 15,),

                  Expanded(
                    child: Center(
                      child: myWheel(cubit:cubit),
                    ),
                  ),

                  // const Spacer(),
                  //
                  // defaultButton(
                  //   type: ButtonType.elevated,
                  //   onPressed: spinWheel,
                  //   message: Localization.translate('spin'),
                  // ),

                ],
              ),
            ),
            fallback: (context)=>Center(child: defaultProgressIndicator(context: context)),
          );
        },

    );
  }

  ///Wheel Settings
  Widget myWheel({required AppCubit cubit,})
  {
    return LayoutBuilder(builder: (context,constraints)
    {
      double maxSize = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight; // Take the smaller dimension for responsiveness

      // Calculate sizes dynamically based on available space
      double wheelSize = maxSize * 0.9; // 90% of the available width
      double borderSize = wheelSize * 1.3; // Border image slightly larger than the wheel


      return Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
              child: SizedBox(
                width: borderSize,
                height: borderSize,
                child: Image(
                  image: AssetImage('assets/images/others/border4.png'),
                  color: cubit.isDarkTheme? Colors.white : Colors.black,
                  filterQuality: FilterQuality.high,
                ),
              )
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

              onAnimationEnd: ()
              {
                stopWheelSound();

                _dialog(context: context, cubit: cubit);
              },

              onFling: ()
              {
                spinWheel();
              },

              animateFirst: false,

              styleStrategy: AlternatingStyleStrategy(),

              onFocusItemChanged: (index)
              {
                // print(cubit.items?.items?[index].label);
              },

              items: cubit.items!.items!.asMap().entries.map((element)
              {
                int index = element.key; // Get the index
                var choice = element.value; // Get the item

                // Select color based on index
                Color fillColor = AppCubit.currentColorChoice == 'manual'
                    ?choice.color!
                    :cubit.wheelColors[index % cubit.wheelColors.length];

                return FortuneItem(
                  child: Text(
                    choice.label!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppCubit.language == 'ar'
                            ?'Cairo'
                            :'WithoutSans'
                    ),
                  ),
                  style: FortuneItemStyle(
                      color: fillColor,
                      textStyle: generateTextStyle(fillColor),
                      borderWidth: cubit.isDarkTheme? 3 : 2,
                      borderColor: Colors.black
                  ),
                );
              },).toList(),

              // alignment: Alignment.center,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
              shouldLoop: true, // start again as soon as the animation is finished
              createParticlePath: drawStar, // define a custom shape/path.
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _controllerCenterLeft,
              blastDirection: 0, // radial value - RIGHT
              emissionFrequency: 0.6,
              // set the minimum potential size for the confetti (width, height)
              minimumSize: const Size(10, 10),
              // set the maximum potential size for the confetti (width, height)
              maximumSize: const Size(50, 50),
              numberOfParticles: 1,
              gravity: 0.1,
              shouldLoop: true,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _controllerCenterRight,
              blastDirection: pi, // radial value - LEFT
              particleDrag: 0.05, // apply drag to the confetti
              emissionFrequency: 0.05, // how often it should emit
              numberOfParticles: 20, // number of particles to emit
              gravity: 0.05, // gravity - or fall speed
              shouldLoop: true,
              strokeWidth: 1,
              strokeColor: Colors.white,
            ),
          ),
        ],
      );
    });
  }

  ///Show Dialog with the result
  void _dialog({required BuildContext context, required AppCubit cubit})
  {
    if(cubit.currentItem !=null)
    {
      _resultSound(cubit.currentItem!.type!);

      showDialog(
          context: context,
          builder: (dialogContext)
          {
            return defaultAlertDialog(
              context: dialogContext,
              title: cubit.currentItem?.type == ItemType.win
                  ?Localization.translate('result_title_winning')
                  :cubit.currentItem?.type == ItemType.loose
                      ?Localization.translate('result_title_loose')
                      :Localization.translate('result_title_tie'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                    Text(
                      Localization.translate('spin_result'),
                      style: textStyleBuilder(),
                    ),

                    const SizedBox(height: 5,),

                    Text(
                      cubit.currentItem?.label ?? '',
                      style: textStyleBuilder(fontWeight: FontWeight.w600, fontSize: 24),
                    ),
                  ],
                ),
              ),

              titleStyle: headlineStyleBuilder(fontWeight: FontWeight.w600, fontSize: 22),


            );
          },
      ).then((_)
      {
        // Dialog dismissed callback
        _controllerCenterLeft.stop();
        _controllerCenterRight.stop();
        _controllerCenter.stop();
      });
    }

    else
    {
      snackBarBuilder(
          context: context,
          message: '${Localization.translate('result')} ${cubit.currentItem?.label}'
      );
    }
  }

  ///Choose Which Audio to Play With the Dialog
  void _resultSound(ItemType type)
  {
    switch (type)
    {

      case ItemType.win:
        _controllerCenterLeft.play();
        _controllerCenterRight.play();
        _controllerCenter.play();

        _audioPlayer.play(AssetSource('audio/win.mp3'));
        break;

      case ItemType.loose:
        _audioPlayer.play(AssetSource('audio/loose.mp3'));
        break;

      case ItemType.tie:
        break;
    }
  }

}




