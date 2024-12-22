//Token to be cached
import 'dart:ui';

import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';

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
int totalTrials= 100;

List<ItemModel> defaultItems=
[
  ItemModel(id:1, label: '5% Discount', probability: 0.3, type: ItemType.win, remainingAttempts: (0.3 * totalTrials).round() ),
  ItemModel(id:2, label: '15% Discount', probability: 0.1, type: ItemType.win, remainingAttempts: (0.1 * totalTrials).round()),
  ItemModel(id:3, label: '1 More Spin', probability: 0.2, type: ItemType.tie, remainingAttempts: (0.2 * totalTrials).round()),
  ItemModel(id:4, label: 'No Luck', probability: 0.4, type: ItemType.loose, remainingAttempts: (0.4 * totalTrials).round()),
];