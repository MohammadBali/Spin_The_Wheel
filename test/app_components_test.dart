import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:spinning_wheel/shared/components/app_components.dart';

void main()
{
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    // Ensure the necessary bindings are initialized for the test environment
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the platform channel
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return '/mocked/app/documents';
        case 'getTemporaryDirectory':
          return '/mocked/temp';
        case 'getDownloadsDirectory':
          return '/mocked/downloads';
        default:
          return null;
      }
    });
  });

  tearDownAll(() {
    channel.setMockMethodCallHandler(null); // Clean up mocks after tests
  });

  ///Test isNumeric Method
  group('isNumeric',()
  {
    test('isNumeric_pass',()
    {
      expect(isNumeric('6'), true);
    });

    test('isNumeric2_pass',()
    {
      expect(isNumeric('6.1'), true);
    });

    test('isNumeric3_pass',()
    {
      expect(isNumeric('-5.1544'), true);
    });

    test('isNumeric_fail',()
    {
      expect(isNumeric('s'), false);
    });
  });

  ///Test generateHarmoniousColors Method
  group('generateHarmoniousColors',()
  {

    test('generateHarmoniousColors_pass',()
    {
      ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

      expect(generateHarmoniousColors(colorScheme), isA<List<Color>>());
    });

    test('generateHarmoniousColors2_pass',()
    {
      ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

      expect(generateHarmoniousColors(colorScheme, isRainbow: true), isA<List<Color>>());
    });

    test('generateHarmoniousColors3_pass',()
    {
      ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

      expect(generateHarmoniousColors(colorScheme, isRainbow: false), isA<List<Color>>());
    });

    test('generateHarmoniousColors2_pass',()
    {
      ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

      expect(generateHarmoniousColors(colorScheme, isRainbow: true, count: double.maxFinite.toInt()), isA<List<Color>>());
    });

    test('generateHarmoniousColors_null',()
    {
      ColorScheme? colorScheme;

      // Expect the function to throw an error when given null.
      expect(() => generateHarmoniousColors(colorScheme!), throwsA(isA<TypeError>()));
    });

    test('generateHarmoniousColors_wrongPassing',()
    {
      ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.red);

      int? num = int.tryParse('2a');
      // Expect the function to throw an error when given null.
      expect(() => generateHarmoniousColors(colorScheme, count: num!), throwsA(isA<TypeError>()));
    });
  });

  ///Test[generateTextStyle] Method
  group('generateTextStyle',()
  {
    test('generateTextStyle_pass',()
    {
      Color fillColor = Colors.green;
      expect(generateTextStyle(fillColor), isA<TextStyle>());
    });

    test('generateTextStyle_fail',()
    {
      Color? fillColor;

      expect(()=>generateTextStyle(fillColor!), throwsA(isA<TypeError>()));
    });
  });

  ///Test[hexCodeExtractor] Method
  group('hexCodeExtractor',()
  {
    test('hexCodeExtractor_pass',()
    {
      expect(hexCodeExtractor(Colors.red), isA<String>());
    });

    test('hexCodeExtractor2_pass',()
    {
      expect(hexCodeExtractor(Colors.green), isA<String>());
    });
    
    test('hexCodeExtractor_fail',()
    {
      expect(()=>hexCodeExtractor(HexColor('')),throwsA(isA<FormatException>()));
    });
  });

  ///Test[drawStar] Method
  group('drawStar',()
  {
    test('drawStar_pass',()
    {
      Size s = Size(5,4);
      expect(drawStar(s), isA<Path>());
    });

    test('drawStar2_pass',()
    {
      Size s = Size(0,0);
      expect(drawStar(s), isA<Path>());
    });

    test('drawStar3_pass',()
    {
      Size s = Size(-5,-4);
      expect(drawStar(s), isA<Path>());
    });

    test('drawStar4_pass',()
    {
      Size s = Size(double.maxFinite, double.maxFinite);
      expect(drawStar(s), isA<Path>());
    });

    test('drawStar5_pass',()
    {
      Size s = Size(double.infinity, double.infinity);
      expect(drawStar(s), isA<Path>());
    });
  });

  ///Test[getPath] Method
  group('getPath',()
  {
    test('getPath_pass', () async {
      final result = await getPath();
      expect(result, isA<String>());
      expect(result, contains('/mocked')); // Validate mocked path
    });
  });
}

