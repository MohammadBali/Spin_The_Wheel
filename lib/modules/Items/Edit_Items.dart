import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';

class EditItems extends StatefulWidget {
  ItemModel item;
  EditItems({super.key, required this.item});

  @override
  State<EditItems> createState() => _EditItemsState();
}

class _EditItemsState extends State<EditItems> {

  TextEditingController labelController = TextEditingController();
  TextEditingController probabilityController = TextEditingController();
  TextEditingController colorController = TextEditingController();

  String? type;
  late Color currentColor;
  var formKey=GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();

    labelController.value = TextEditingValue(text: widget.item.label ?? 'NAME');
    probabilityController.value = TextEditingValue(text: widget.item.probability.toString());
    colorController.value = TextEditingValue(text: hexCodeExtractor(widget.item.color!));
    currentColor = widget.item.color!;
    type = widget.item.type?.name;

  }

  @override
  void dispose() {
    labelController.dispose();
    probabilityController.dispose();
    colorController.dispose();
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
                        style: headlineStyleBuilder(fontSize: 24),
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
                        Localization.translate('item_color'),
                        style: textStyleBuilder(),
                      ),

                      const SizedBox(height: 10,),

                      defaultTextFormField(
                        controller: colorController,
                        readOnly: true,
                        keyboard: TextInputType.text,
                        label: Localization.translate('item_color'),
                        prefix: Icons.color_lens_outlined,
                        validate: (value)
                        {
                          if(value==null || value.isEmpty)
                          {
                            return Localization.translate('empty_value');
                          }
                          return null;
                        },

                        onTap: ()
                        {
                          _colorDialog(context);
                        }
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
                                  Localization.translate(value.name),
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
                                widget.item.remainingAttempts =  (num.tryParse(probabilityController.value.text)! * totalTrials).round();
                                widget.item.color = currentColor;
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

  ///Color Dialog to Choose a Color
  void _colorDialog(BuildContext context)
  {
    showDialog(
        context: context,
        builder: (dialogContext)
        {
          return defaultAlertDialog(
            context: dialogContext,
            title: Localization.translate('pick_color'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: widget.item.color!,
                    onColorChanged: (Color c)
                    {
                      setState(() {
                        currentColor = c;
                      });
                    },
                  ),
              
                  const SizedBox(height: 5,),
              
                  defaultButton(
                    message: Localization.translate('submit_button'),
                    type: ButtonType.elevated,
                    onPressed: ()
                    {
                      setState(() {
                        colorController.value = TextEditingValue(text: hexCodeExtractor(currentColor));
                      });
              
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
