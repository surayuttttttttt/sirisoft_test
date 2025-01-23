import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sirisoft_test/controller.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'fetch_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  BitCoinController bitCoinController = Get.put(BitCoinController());
  group('Fetch data from bitCoinController', () {
    late MockClient mockClient;
    setUp(() {
      mockClient = MockClient();
    });

    test('fetches bitcoin price success', () async {
      //read mock json files
      final mockJson = await rootBundle.loadString('assets/mock_response.json');

      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response(mockJson, 200));

      final result = await bitCoinController.fetch(client: mockClient);

      expect(result, isNotNull);
      expect(
        result?.bpi['USD']?.rate,
        '105,226.323',
      );
      expect(
        result?.bpi['THB']?.rate,
        '3,631,623.484',
      );
      expect(result?.time.updatedIso.toIso8601String(),
          "2025-01-23T18:55:25.000Z");
    });

    test('throws an exception when fetch failed', () async {
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('Not Found', 401));
      expect(
        () async => await bitCoinController.fetch(client: mockClient),
        throwsA(isA<Exception>()),
      );
    });
  });
}
