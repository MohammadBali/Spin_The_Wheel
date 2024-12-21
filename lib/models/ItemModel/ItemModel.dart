class ItemsModel
{
  List<ItemModel>? items=[];

  ItemsModel.fromItems(List<ItemModel> itemsToAdd)
  {
    items?.addAll(itemsToAdd);
  }

  ItemsModel.fromJson(List<Map<String,dynamic>>json)
  {
    for (var item in json ?? [])
    {
      items?.add(ItemModel.fromJson(item));
    }
  }

  addSingleItem(Map<String,dynamic> item)
  {
    items?.add(ItemModel.fromJson(item));
  }

}


class ItemModel
{
  int? id;
  String? label;
  num? probability;
  ItemType? type;

  ItemModel.fromJson(Map<String,dynamic>json)
  {
    id = json['id'];
    label = json['label'];
    probability = json['probability'];
    type = ItemType.values.byName( json['type']);
  }

  ItemModel({required this.id, required this.label, required this.probability, required this.type});

  @override
  String toString() {
    return 'ItemModel:\n'
        'id: $id\n'
        'label: $label\n'
        'type: $type\n'
        'probability: $probability\n';
  }
}



enum ItemType
{
  win,
  loose,
  tie,
}