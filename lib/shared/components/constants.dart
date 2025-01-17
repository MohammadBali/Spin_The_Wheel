//Token to be cached
import 'dart:ui';

import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';

import 'Imports/default_imports.dart';

String token='';

String refreshToken='';

enum ButtonType
{
  filled,
  filledTonal,
  outlined,
  elevated,
  text,
}

//Setting devices types
Set<PointerDeviceKind> dragDevices={PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad};

///Total Trials
int totalTrials= 1000;

///DateFormat for the log date style
DateFormat logDateFormatter = DateFormat('dd-MM-yyy HH.mm.ss');

///Default Items to build on the first app run
List<ItemModel> defaultItems=
[
  ItemModel(id:1, label: 'حسم 5%', probability: 0.3, type: ItemType.win, remainingAttempts: (0.3 * totalTrials), color: HexColor('D0EFB1') ),
  ItemModel(id:2, label: '100 دولار كاش', probability: 0.001, type: ItemType.win, remainingAttempts: (0.001 * totalTrials), color: HexColor('B3D89C')),
  ItemModel(id:3, label: 'قطعة مجاناً', probability: 0.01, type: ItemType.win, remainingAttempts: (0.01 * totalTrials), color: HexColor('9DC3C2')),
  ItemModel(id:4, label: 'حظ اوفر', probability: 0.3, type: ItemType.loose, remainingAttempts: (0.3 * totalTrials), color: HexColor('77A6B6')),
  ItemModel(id:5, label: 'حسم 25%', probability: 0.1, type: ItemType.win, remainingAttempts: (0.1 * totalTrials), color: HexColor('4D7298')),
  ItemModel(id:6, label: 'حسم 50%', probability: 0.039, type: ItemType.win, remainingAttempts: (0.039 * totalTrials), color: HexColor('F25757')),
  ItemModel(id:7, label: 'حسم 10%', probability: 0.25, type: ItemType.win, remainingAttempts: (0.25 * totalTrials), color: HexColor('F2E863')),
];

///Dimming Value for Screen
const double dimValue =0.75;

const int scaleFactor = 1000;

const Color dimColor = Colors.black;