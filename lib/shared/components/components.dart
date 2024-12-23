import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinning_wheel/layout/cubit/cubit.dart';
import 'package:spinning_wheel/shared/components/Localization/Localization.dart';
import 'package:spinning_wheel/shared/components/constants.dart';
import 'package:spinning_wheel/shared/styles/colors.dart';

///Gets The current Color Scheme
ColorScheme currentColorScheme(BuildContext context) => AppCubit.get(context).isDarkTheme? darkColorScheme : lightColorScheme;

//------------------------------------------------------------------------------------------\\

///Convert a Color to MaterialColor
MaterialColor getMaterialColor(Color color) {
  final Map<int, Color> shades = {
    50:  const Color.fromRGBO(136, 14, 79, .1),
    100: const Color.fromRGBO(136, 14, 79, .2),
    200: const Color.fromRGBO(136, 14, 79, .3),
    300: const Color.fromRGBO(136, 14, 79, .4),
    400: const Color.fromRGBO(136, 14, 79, .5),
    500: const Color.fromRGBO(136, 14, 79, .6),
    600: const Color.fromRGBO(136, 14, 79, .7),
    700: const Color.fromRGBO(136, 14, 79, .8),
    800: const Color.fromRGBO(136, 14, 79, .9),
    900: const Color.fromRGBO(136, 14, 79, 1),
  };
  return MaterialColor(color.value, shades);
}

//------------------------------------------------------------------------------------------\\

///SnackBarBuilder, creates a ScaffoldMessenger ShowSnackBar
///* [context] Current Context to show the snack bar in
///* [message] Snack's message
///* [quitMessage] The Action button on the end
///* [onPressed] optional, onPressed will hide the snack by default
void snackBarBuilder(
{
  required BuildContext context,
  required String message,
  String? quitMessage,
  void Function()? onPressed,
})
{
  ScaffoldMessenger.of(context).showSnackBar(
      defaultSnackBar(
          message: message,
          quitMessage: quitMessage ?? Localization.translate('exit'),
          onPressed: onPressed,
      ),
  );
}

//------------------------------------------------------------------------------------------\\

///Default SnackBar Builder
SnackBar defaultSnackBar(
{
  required String message,
  String? quitMessage,
  void Function()? onPressed,

})=>SnackBar(
  content: Text(message, maxLines: 4, overflow: TextOverflow.ellipsis,),
  action: SnackBarAction(
    label: quitMessage ?? Localization.translate('exit'),
    onPressed: onPressed?? (){},

  ),
);

//------------------------------------------------------------------------------------------\\

///Default Button Builder
///* [type] Specify The Button Type
///* [onPressed] On Press Handle
///* [message] Message to be shown, SUBMIT as default value
///* [customChild] Custom Child instead of Text if needed
Widget defaultButton(
{
  required ButtonType type,
  void Function()? onPressed,
  String message='SUBMIT',
  Widget? customChild,
})
{
  switch (type)
  {
    case ButtonType.filled:
      return FilledButton(onPressed: onPressed, child: customChild?? Text(message),);

    case ButtonType.filledTonal:
      return FilledButton.tonal(onPressed: onPressed, child: customChild?? Text(message));

    case ButtonType.outlined:
      return OutlinedButton(onPressed: onPressed, child: customChild?? Text(message));

    case ButtonType.elevated:
      return ElevatedButton(onPressed: onPressed, child: customChild?? Text(message));

    case ButtonType.text:
      return TextButton(onPressed: onPressed, child: customChild?? Text(message), );


  }
}

//------------------------------------------------------------------------------------------\\

///Show Default Modal Bottom Sheet
///*[height] Custom Height, default to quarter of the screen
///*[customChild] Fully Custom Child
///*[child] Child inside the default main Child (with quit button)
///*[]
void defaultModalBottomSheet(
{
  required BuildContext context,
  bool showDragHandle=true,
  double? height,

  Widget? customChild,
  Widget? child,

  String defaultButtonMessage = 'Close',
  ButtonType defaultButtonType = ButtonType.outlined,
  void Function(BuildContext bottomSheetContext)? onPressed,
  bool popAfterButton=true,
})
{
  showModalBottomSheet(
      context: context,
      backgroundColor: currentColorScheme(context).surfaceContainerLow,
      showDragHandle: showDragHandle,
      // enableDrag: true,
      builder: (BuildContext bottomSheetContext)
      {
        return customChild?? SizedBox(
          //height: height?? MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children:
                [
                  if(child!=null) child,
              
                  const SizedBox(height: 10,),

                  Align(
                    alignment: AlignmentDirectional.center,
                    child: defaultButton(
                      message: defaultButtonMessage,
                      type: defaultButtonType,
                      onPressed:()
                      {
                        onPressed!=null? onPressed(bottomSheetContext) : null;
                        popAfterButton? Navigator.of(bottomSheetContext).pop() : null;
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
  );
}

//------------------------------------------------------------------------------------------\\

///Default Alert Dialogs

Widget defaultAlertDialog(
    {
      required BuildContext context,
      required String title,
      required Widget content,
      TextStyle? titleStyle,
      ShapeBorder? shape,
    })
{
  return AlertDialog(
    shape: shape,
    title: Text(
      title,
      textAlign: TextAlign.center,
      style: titleStyle,
    ),

    content: content,

    backgroundColor: currentColorScheme(context).surfaceContainerHigh,

    //elevation: 50,

    // contentTextStyle: TextStyle(
    //     fontSize: 16,
    //     color:  AppCubit.get(context).isDarkTheme? Colors.white: Colors.black,
    //     //fontFamily: AppCubit.language =='ar'? 'Cairo' :'Railway',
    //     fontWeight: FontWeight.w400
    // ),
    //
    // titleTextStyle: TextStyle(
    //   fontSize: 24,
    //   color:  AppCubit.get(context).isDarkTheme? Colors.white: Colors.black,
    //   fontWeight: FontWeight.w800,
    //   fontFamily: AppCubit.language =='ar'? 'Cairo' :'Poppins',
    // ),
    //


  );
}

//--------------------------------------------------------------------------------------------------\\

///Default Divider
///*[color] Color, nullable
///*[height] Divider Height, nullable & default with 1dp
///*[symmetricIndent] Indent for leading and trailing
Widget defaultDivider({Color? color, double? height, double? symmetricIndent}) => Divider(
  color: color,
  height: height,
  indent: symmetricIndent,
  endIndent: symmetricIndent,
);

//--------------------------------------------------------------------------------------------------\\

///Default List Tile Builder
///*[isThreeLine] is The Subtitle Three Line?
///*[customLeading] Provide a Custom Widget instead of Icon
///*[leadingAndTrailingTextStyle] Provide a custom Text Style
Widget defaultListTile(
{
  IconData? leadingIcon,
  Widget? customLeading,

  IconData? trailingIcon,
  Widget? customTrailing,

  String? title,
  Widget? customTitle,

  String? subtitle,
  Widget? customSubtitle,

  bool enabled = true,
  bool isThreeLine = false,
  bool selected = false,

  TextStyle? leadingAndTrailingTextStyle,
  TextStyle? subtitleTextStyle,

  void Function()? onTap,
  void Function()? onLongPress,

})=>ListTile(
  leading: customLeading?? (leadingIcon !=null? Icon(leadingIcon) : null),
  title: customTitle?? Text(title!),
  subtitle: customSubtitle?? Text(subtitle!),
  trailing: customTrailing?? (trailingIcon !=null? Icon(trailingIcon) : null),

  onTap: onTap,
  onLongPress: onLongPress,

  enabled: enabled,
  isThreeLine: isThreeLine,
  selected: selected,

  leadingAndTrailingTextStyle: leadingAndTrailingTextStyle,
  subtitleTextStyle: subtitleTextStyle,

);

//---------------------------------------------------------------------------------\\

///Default Linear Loading Indicator

Widget defaultLinearProgressIndicator({required BuildContext context, double? value, bool? isCustomColor=false})
{
  return LinearProgressIndicator(
    backgroundColor: isCustomColor?? AppCubit.get(context).isDarkTheme? defaultSecondaryDarkColor : defaultThirdColor,
    value: value,

  );
}

///Default Circular Loading Indicator
Widget defaultProgressIndicator({required BuildContext context, double? value, bool? isCustomColor=false})
{
  return CircularProgressIndicator(
    backgroundColor: isCustomColor?? AppCubit.get(context).isDarkTheme? defaultSecondaryDarkColor : defaultThirdColor,
    value: value,
  );
}


//------------------------------------------------------------------------------------------\\

///Default TabBar Builder
///* [isPrimary] if true => use TabBar, otherwise use TabBar.secondary
///* [tabs] Children, usually each widget is Tab with parameters of text & Icon for Primary
///* Use it with TabBarView and pass a ~Controller to handle changes
///* Or Use a DefaultTabBarController
///* Refer to https://api.flutter.dev/flutter/material/TabBar-class.html
PreferredSizeWidget defaultTabBar(
{
  required bool isPrimary,
  bool isScrollable=false,

  required List<Widget> tabs,
  required BuildContext context,
  TabController? controller,

  ScrollPhysics physics= const BouncingScrollPhysics(),
  void Function(int)? onTap,



})=>isPrimary
    ?TabBar(
      controller: controller,
      tabs: tabs,
      physics: physics,
      isScrollable: isScrollable,
      onTap: onTap?? (index){AppCubit.get(context).changeTabBar(index);},
)
    :TabBar.secondary(
      controller: controller,
      tabs: tabs,
      physics: physics,
      isScrollable: isScrollable,
      onTap: onTap?? (index){AppCubit.get(context).changeTabBar(index);},
);

//------------------------------------------------------------------------------------------\\

///Returns the directionality
TextDirection appDirectionality()
{
  return AppCubit.language=='ar' ? TextDirection.rtl : TextDirection.ltr;
}

//------------------------------------------------------------------------------------------\\

///Default TextFormField Styling
Widget defaultTextFormField({
  required TextEditingController controller,
  required TextInputType keyboard,
  required String label,
  required IconData prefix,
  required String? Function(String?)? validate,
  IconData? suffix,
  bool isObscure = false,
  bool isClickable = true,
  void Function(String)? onSubmit,
  void Function()? onPressedSuffixIcon,
  void Function()? onTap,
  void Function(String)? onChanged,
  void Function(String?)? onSaved,
  void Function(PointerDownEvent)? onTapOutside,
  InputBorder? focusedBorderStyle,
  InputBorder? borderStyle,
  TextStyle? labelStyle,
  Color? prefixIconColor,
  Color? suffixIconColor,
  TextInputAction? inputAction,
  double borderRadius=8,
  double contentPadding=25,
  bool readOnly=false,
  int? digitsLimits,

  bool isFilled=false,
  Color? fillColor,
}) =>
    TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboard,
      onTapOutside: onTapOutside?? (event) {FocusManager.instance.primaryFocus?.unfocus();},
      onFieldSubmitted: onSubmit,
      textInputAction: inputAction,
      validator: validate,
      enabled: isClickable,
      readOnly: readOnly,
      onTap: onTap,
      onSaved: onSaved,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: isFilled,
        fillColor: fillColor,
        border:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: focusedBorderStyle,
        enabledBorder: borderStyle,
        labelStyle: labelStyle,
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: contentPadding),
        prefixIcon: Icon(prefix, color: prefixIconColor,),
        suffixIcon: IconButton(
          onPressed: onPressedSuffixIcon,
          icon: Icon(
            suffix,
            color: suffixIconColor,
          ),
        ),
      ),
      inputFormatters:
      [
        LengthLimitingTextInputFormatter(digitsLimits),
      ],
    );

//--------------------------------------------------------------------------------------------------\\

///Default Form Field Styling

Widget defaultFormField({
  required BuildContext context,
  InputBorder focusedBorder = InputBorder.none,
  InputBorder? border,
  TextStyle? errorStyle,
  String? errorText,
  String? labelText,
  String? helperText,
  String? hintText,
  TextStyle? dropDownButtonTextStyle,
  String? dropDownButtonValue,
  Color? dropDownColor,
  bool isDense = true,
  void Function(String?, FormFieldState<String>)? onChanged,
  List<DropdownMenuItem<String>>? items,
  String? Function(String?)? validator,

})=>FormField<String>(
  builder: (FormFieldState<String> state) {
    return InputDecorator(
      decoration: InputDecoration(
        focusedBorder: focusedBorder,
        errorStyle: errorStyle?? const TextStyle(color: Colors.redAccent, fontSize: 16.0),
        errorText: errorText ?? (state.hasError ? state.errorText : null),
        labelText: labelText,
        helperText: helperText,
        hintText: hintText,
        border: border,
      ),

      child: DropdownButtonHideUnderline(

        child: DropdownButton<String>(
          style: dropDownButtonTextStyle?? TextStyle(
              color: AppCubit.get(context).isDarkTheme? defaultDarkColor : defaultColor,
              fontFamily: AppCubit.language == 'ar'? 'Cairo' : 'Railway'
          ),
          value: dropDownButtonValue,
          isExpanded: true,
          // dropdownColor: dropDownColor ?? (AppCubit.get(context).isDarkTheme? defaultCanvasDarkColor : defaultCanvasColor),
          isDense: isDense,
          onChanged: (newValue) {
            if (onChanged != null)
            {
              onChanged(newValue, state);
            }
          },
          items: items,


        ),
      ),
    );
  },

  validator: validator,
);

//--------------------------------------------------------------------------------------------------\\

/// Navigate to a screen, it takes context and a widget to go to.

void navigateTo(BuildContext context, Widget widget) =>Navigator.push(
  context,
  MaterialPageRoute(builder: (context)=>widget),

);

//--------------------------------------------------------------------------------------------------\\

/// Navigate to a screen and destroy the ability to go back
void navigateAndFinish(context,Widget widget) => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context)=>widget),
      (route) => false,  // The Route that you came from, false will destroy the path back..
);


//------------------------------------------------------------------------------------------\\

///Text Style builder

TextStyle textStyleBuilder({
  double fontSize=20,
  FontWeight fontWeight=FontWeight.normal,
  String? fontFamily,
  Color? color,
  TextDecoration decoration = TextDecoration.none

})=>TextStyle(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color:color ,
  decoration: decoration,
);


TextStyle headlineStyleBuilder({
  double fontSize=20,
  FontWeight fontWeight=FontWeight.w600,
  String? fontFamily,
  Color? color,
  TextDecoration decoration = TextDecoration.none

})=>TextStyle(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color:color ,
  decoration: decoration,
  fontFamily: fontFamily
);

//------------------------------------------------------------------------------------------\\