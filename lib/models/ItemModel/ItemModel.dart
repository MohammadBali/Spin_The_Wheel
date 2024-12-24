import 'dart:ui';

import 'package:hexcolor/hexcolor.dart';
import 'package:spinning_wheel/shared/components/constants.dart';

class ItemsModel
{
  List<ItemModel>? items=[];

  ItemsModel.fromItems(List<ItemModel> itemsToAdd)
  {
    items?.addAll(itemsToAdd);
  }

  ItemsModel.fromJson(List<Map<String,dynamic>>json)
  {
    for (var item in json)
    {
      ItemModel i = ItemModel.fromJson(item);

      if(!isMatch(i))
      {
        items?.add(i);
      }
    }
  }

  addSingleItem(Map<String,dynamic> item)
  {
    items?.add(ItemModel.fromJson(item));
  }

  ///Checks if a passed model already exactly exists
  bool isMatch(ItemModel model)
  {
    for(ItemModel item in items ?? [])
    {
      if(item.id == model.id && item.remainingAttempts == model.remainingAttempts && item.probability == model.probability && item.type == model.type && item.label == model.label)
      {
        return true;
      }
    }

    return false;
  }

}

class ItemModel
{
  int? id;
  String? label;
  num? probability; //probability of occurring
  ItemType? type;
  num? remainingAttempts; //dependent probabilities
  Color? color;

  ItemModel.fromJson(Map<String,dynamic>json)
  {
    id = json['id'];
    label = json['label'];
    probability = json['probability'];
    type = ItemType.values.byName( json['type']);
    remainingAttempts = json['remainingAttempts'];
    color = HexColor(json['color']);
  }

  ///If manual reinitializing was needed
  void initializeRemainingAttempts()
  {
    // Allocate remaining attempts based on probability
    remainingAttempts = (probability! * totalTrials).round();
  }

  ItemModel({required this.id, required this.label, required this.probability, required this.type, required this.remainingAttempts, required this.color});

  @override
  String toString() {
    return 'ItemModel:\n'
        'id: $id\n'
        'label: $label\n'
        'type: $type\n'
        'probability: $probability\n'
        'remainingAttempts: $remainingAttempts\n';
  }
}


///Item Type
///[win] Winning -> Delegate a specific sound
///[loose] Loosing -> Delegate a specific loosing sound
///[tie] Tie; like try again or 2 more spins
enum ItemType
{
  win,
  loose,
  tie,
}