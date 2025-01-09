
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinning_wheel/shared/network/local/cache_helper.dart';

void main()
{
  setUpAll(()
  async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  tearDownAll(()
  {
    SharedPreferences.setMockInitialValues({});
  });

  group('cache_helper',()
  {
    test('add_value_pass',() async
    {
      final result = await CacheHelper.saveData(key: 'myKey', value: 2);
      expect(result,true);
    });

    test('putBoolean_pass',() async
    {
      await CacheHelper.putBoolean(key: 'myKey', value: true);
      final result = CacheHelper.getBool(key: 'myKey');
      expect(result,true);

      await CacheHelper.putBoolean(key: 'myKey2', value: false);
      final result2 = CacheHelper.getBool(key: 'myKey2');
      expect(result2,false);
    });

    test('get_unavailable_pass',() async
    {
      final result = await CacheHelper.saveData(key: 'myKey', value: 2);
      expect(result,true);

      await CacheHelper.clearData(key: 'myKey');

      final secondAddon = await CacheHelper.getData(key: 'myKey');

      expect(secondAddon, isA<Null>());
    });

    test('add_get_value_pass',() async
    {
      var save = await CacheHelper.saveData(key: 'myKey', value: 2);

      expect(save, true);

      var result = await CacheHelper.getData(key: 'myKey');

      expect(result, 2);
    });
  });
}