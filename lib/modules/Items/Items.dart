import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/modules/Items/Edit_Items.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';
import 'package:string_extensions/string_extensions.dart';

class AllItems extends StatefulWidget {
  const AllItems({super.key});

  @override
  State<AllItems> createState() => _AllItemsState();
}

class _AllItemsState extends State<AllItems> {

  var formKey=GlobalKey<FormState>();

  TextEditingController labelController = TextEditingController();
  TextEditingController probabilityController = TextEditingController();
  String? type;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (context,state){},
      builder: (context,state)
      {
        var cubit = AppCubit.get(context);
        var items = cubit.items;
        return Directionality(
          textDirection: appDirectionality(),
          child: Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                [
                  Text(
                    Localization.translate('items'),
                    style: headlineStyleBuilder(fontSize: 24),
                  ),

                  const SizedBox(height: 20,),

                  ConditionalBuilder(
                    condition: items !=null,
                    builder: (context)=>Expanded(
                      child: ListView.separated(
                          itemBuilder: (context,index)=> itemBuilder(item: items.items![index], context: context, cubit: cubit, index: index),
                          separatorBuilder: (context,index)=> const SizedBox(height: 10,),
                          itemCount: items!.items!.length
                      ),
                    ),
                    fallback: (context)=> LinearProgressIndicator()
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                defaultModalBottomSheet(
                    context: context,
                    popAfterButton: false,
                    defaultButtonMessage: Localization.translate('submit_button'),
                    child: StatefulBuilder(builder: (context,setState)
                    {
                      return Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                          [
                            Center(
                              child: Text(
                                Localization.translate('new_item'),
                                style: headlineStyleBuilder(),
                              ),
                            ),

                            const SizedBox(height: 5,),

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
                              dropDownButtonValue: type,
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
                          ],
                        ),
                      );
                    }),

                    onPressed: (bottomSheetContext)
                    {
                      if(formKey.currentState!.validate())
                      {
                        cubit.insertIntoDatabase(
                          label: labelController.value.text,
                          type: ItemType.values.byName(type!),
                          probability: num.parse(probabilityController.value.text)
                        );

                        labelController.value = TextEditingValue.empty;
                        probabilityController.value = TextEditingValue.empty;

                        // Close the bottom sheet
                        Navigator.of(bottomSheetContext).pop();
                      }
                    }

                );
              },
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget itemBuilder({required ItemModel? item, required BuildContext context, required AppCubit cubit, required int index,})
  {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          defaultListTile(
            title: item?.label,
            subtitle: '${Localization.translate('item_probability')}: ${item?.probability}',
            enabled: true,
            customLeading: Text('${index + 1}'),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children:
            [
              defaultButton(
                  message: Localization.translate('edit'),
                  type: ButtonType.text,
                  onPressed: ()
                  {
                    navigateTo(context, EditItems(item: item!,));
                  }
              ),

              defaultButton(
                message: Localization.translate('delete'),
                type: ButtonType.text,
                onPressed: ()
                {
                  cubit.deleteDatabase(id: item!.id!);
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}
