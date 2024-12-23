import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/modules/Items/Edit_Items.dart';
import 'package:spinning_wheel/shared/components/Imports/default_imports.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';

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
                      return Directionality(
                        textDirection: appDirectionality(),
                        child: Form(
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
                            ],
                          ),
                        ),
                      );
                    }),

                    onPressed: (bottomSheetContext)
                    {
                      if(formKey.currentState!.validate())
                      {
                        //Todo: Fix COLOR
                        cubit.insertIntoDatabase(
                          label: labelController.value.text,
                          type: ItemType.values.byName(type!),
                          probability: num.parse(probabilityController.value.text),
                          remainingAttempts: (num.parse(probabilityController.value.text) * totalTrials).round(),
                          color: ''
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
            subtitle: '${Localization.translate('item_probability')} ${Localization.translate('in_100')}: ${item?.probability}\n${Localization.translate('item_remainingAttempts')}: ${item?.remainingAttempts}',
            isThreeLine: true,
            enabled: true,
            customLeading: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w600),),
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
                  _deleteDialog(context: context, item: item!, cubit: cubit);
                }
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _deleteDialog({required BuildContext context, required ItemModel item, required AppCubit cubit,})
  {
    showDialog(
        context: context,
        builder: (dialogContext)
        {
          return defaultAlertDialog(
            context: dialogContext,
            title: Localization.translate('delete_item'),
            content: Directionality(
              textDirection: appDirectionality(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                    Text(Localization.translate('delete_item_secondary')),

                    const SizedBox(height: 5,),

                    Row(
                      children:
                      [
                        TextButton(
                            onPressed: ()
                            {
                              cubit.deleteDatabase(id: item.id!);
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: Text(Localization.translate('exit_app_yes'))
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: ()=> Navigator.of(dialogContext).pop(false),
                          child: Text(Localization.translate('exit_app_no')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
