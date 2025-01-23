import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sirisoft_test/controller.dart';

void main() {
  BitCoinController bitCoinController = Get.put(BitCoinController());
  group('test formatNumber function in BitCoinController', () {
    test('formats numbers with commas', () {
      expect(bitCoinController.formatNumber(1234567.89), '1,234,567.89');
    });

    test('formats ten', () {
      expect(bitCoinController.formatNumber(99), '99');
    });

    test('formats hundred', () {
      expect(bitCoinController.formatNumber(123.45), '123.45');
    });

    test('formats millions', () {
      expect(bitCoinController.formatNumber(9999999), '9,999,999');
    });

    test('formats negative', () {
      expect(bitCoinController.formatNumber(-555.55), '-555.55');
    });

    test('formats zero correctly', () {
      expect(bitCoinController.formatNumber(0), '0');
    });
  });
}
