import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spinning_wheel/models/ItemModel/ItemModel.dart';
import 'package:spinning_wheel/shared/components/constants.dart';


List<ItemModel> testItems=
[
  ItemModel(id:1, label: 'حسم 5%', probability: 0.3, type: ItemType.win, remainingAttempts: (0.3 * totalTrials), color: HexColor('D0EFB1') ),
  ItemModel(id:2, label: '100 دولار كاش', probability: 0.001, type: ItemType.win, remainingAttempts: (0.001 * totalTrials), color: HexColor('B3D89C')),
  ItemModel(id:3, label: 'قطعة مجاناً', probability: 0.01, type: ItemType.win, remainingAttempts: (0.01 * totalTrials), color: HexColor('9DC3C2')),
  ItemModel(id:4, label: 'حظ اوفر', probability: 0.3, type: ItemType.loose, remainingAttempts: (0.3 * totalTrials), color: HexColor('77A6B6')),
  ItemModel(id:5, label: 'حسم 25%', probability: 0.1, type: ItemType.win, remainingAttempts: (0.1 * totalTrials), color: HexColor('4D7298')),
  ItemModel(id:6, label: 'حسم 50%', probability: 0.039, type: ItemType.win, remainingAttempts: (0.039 * totalTrials), color: HexColor('F25757')),
  ItemModel(id:7, label: 'حسم 10%', probability: 0.25, type: ItemType.win, remainingAttempts: (0.25 * totalTrials), color: HexColor('F2E863')),
];

void main()
{
  group('logic_test',()
  {
    test('dependent_trial_test', ()
    {
      for(int i=0; i<1000; i++)
      {

        int index = getDependentRandomIndexTest();

        expect(index, isA<int>());
      }

      for(int i=0; i<7;i++)
      {
        print('After 1000 Turn, Checking values...');
        expect(testItems[i].remainingAttempts, 0.0);
        print('Expecting Item:${testItems[i].label} to have 0 Remaining Attempts, Value is: ${testItems[i].remainingAttempts} => Correct');

        print('---------------------');
      }

    });
  });
}

///Dependent Item Choosing, with scaling factor
int getDependentRandomIndexTest() {
  try
  {

    // Calculate the total remaining attempts
    double totalRemaining = testItems.fold(0, (sum, item) => sum + item.remainingAttempts!.toDouble());

    print('Total Remaining is: $totalRemaining');

    //Reset the remaining attempts if total remaining is 0
    if (totalRemaining == 0.0)
    {
      print('--------------------------------------------------');
      print('RESETTING VALUES');
      print('--------------------------------------------------');
      for (var item in testItems)
      {
        item.initializeRemainingAttempts();
      }

      totalRemaining = testItems.fold(0, (sum, item) => sum + item.remainingAttempts!.toDouble());

      if (totalRemaining == 0.0) {
        throw Exception("No items with remaining attempts after reset.");
      }
    }

    //Scaling the items with weights so we can measure the fractions
    List<double> scaledWeights = testItems.map((item) => item.remainingAttempts!.toDouble() * scaleFactor).toList();

    // Calculate total weight for random selection
    double totalWeight = scaledWeights.reduce((a, b) => a + b);

    // Random selection based on remaining attempts
    final random = Random();
    double randValue = random.nextDouble() * totalWeight;
    double cumulativeWeight = 0.0;

    for (int i = 0; i < testItems.length; i++) {
      cumulativeWeight += scaledWeights[i];
      if (randValue < cumulativeWeight)
      {
        ItemModel item = testItems[i];

        print('Item Before Updating: ${item.label} - ${item.remainingAttempts}');

        // Update remaining attempts for the selected item
        item.remainingAttempts = (item.remainingAttempts!.toDouble() - 1).clamp(0.0, totalRemaining);

        print('Item After Updating: ${item.label} - ${item.remainingAttempts}');

        print('---------------------');
        return i;
      }
    }

    throw Exception("Failed to select an item based on weights.");
  } catch (e)
  {
    print('ERROR WHILE GETTING DEPENDENT RANDOM INDEX..., ${e.toString()}');
  }
  return -1;
}