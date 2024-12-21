import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';
import 'package:string_extensions/string_extensions.dart';

class EditItems extends StatefulWidget {
  ItemModel item;
  EditItems({super.key, required this.item});

  @override
  State<EditItems> createState() => _EditItemsState();
}

class _EditItemsState extends State<EditItems> {

  TextEditingController labelController = TextEditingController();
  TextEditingController probabilityController = TextEditingController();
  String? type;
  var formKey=GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();

    labelController.value = TextEditingValue(text: widget.item.label ?? 'NAME');
    probabilityController.value = TextEditingValue(text: widget.item.probability.toString());
    type = widget.item.type?.name;

  }

  @override
  void dispose() {
    labelController.dispose();
    probabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state)
      {
        var cubit = AppCubit.get(context);
        return Directionality(
          textDirection: appDirectionality(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(Localization.translate('edit')),
            ),

            body: Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                    [
                      Text(
                        Localization.translate('item_details'),
                        style: headlineStyleBuilder(),
                      ),

                      const SizedBox(height: 20,),

                      Text(
                        Localization.translate('item_name'),
                        style: textStyleBuilder(),
                      ),

                      const SizedBox(height: 10,),

                      defaultTextFormField(
                        controller: labelController,
                        keyboard: TextInputType.text,
                        label: Localization.translate('item_name'),
                        prefix: Icons.abc_outlined,
                        validate: (value)
                        {
                          if(value ==null || value.isEmpty)
                          {
                            return Localization.translate('empty_value');
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20,),

                      Text(
                        Localization.translate('item_probability'),
                        style: textStyleBuilder(),
                      ),

                      const SizedBox(height: 10,),

                      defaultTextFormField(
                        controller: probabilityController,
                        keyboard: TextInputType.number,
                        label: Localization.translate('item_probability'),
                        prefix: Icons.numbers_outlined,
                        validate: (value)
                        {
                          if(value==null || value.isEmpty)
                          {
                            return Localization.translate('empty_value');
                          }

                          if(isNumeric(value) == false)
                          {
                            return Localization.translate('prop_not_a_number');
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20,),

                      Text(
                        Localization.translate('item_type'),
                        style: textStyleBuilder(),
                      ),

                      const SizedBox(height: 10,),

                      defaultFormField(
                        context: context,
                        dropDownButtonValue: '$type',
                        onChanged: (value, formFieldState)
                        {
                          setState(() {
                            type = value;
                          });
                        },
                        items: ItemType.values.map((ItemType value)
                        {
                          return DropdownMenuItem<String>(
                            value: value.name,
                            child: Row(
                              children: [
                                Text(
                                  value.name.capitalize,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 25,),

                      Center(
                        child: defaultButton(
                            message: Localization.translate('submit_button'),
                            type: ButtonType.filledTonal,
                            onPressed: ()
                            {
                              if(formKey.currentState!.validate())
                              {
                                widget.item.label = labelController.value.text;
                                widget.item.type = ItemType.values.byName(type!);
                                widget.item.probability = num.tryParse(probabilityController.value.text);

                                cubit.alterItem(widget.item);
                                Navigator.of(context).pop();
                              }
                            }
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
