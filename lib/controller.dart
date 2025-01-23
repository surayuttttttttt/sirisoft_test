import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirisoft_test/ui_helper.dart';
import 'package:http/http.dart' as http;
import 'package:sirisoft_test/model.dart';
import 'package:intl/intl.dart';

class BitCoinController extends GetxController {
  Rx<DateTime> updated = DateTime.now().obs;
  RxString currentCurrency = 'USD'.obs;
  RxMap<DateTime, double> historyUSD = <DateTime, double>{}.obs;
  RxMap<DateTime, double> historyTHB = <DateTime, double>{}.obs;
  List<PriceData> prices = [];

  Bitcoin? bitcoin;
  RxString latestPriceTHB = "".obs;
  RxString latestPriceUSD = "".obs;

  Future<Bitcoin?> fetch({http.Client? client}) async {
    client ??= http.Client();
    var response = await client.get(
      Uri.parse('https://api.coindesk.com/v1/bpi/currentprice/THB.json'),
    );

    Bitcoin res = bitcoinFromJson(response.body);
    updated.value = res.time.updatedIso.toLocal();

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to fetch Bitcoin data. with status code ${response.statusCode}');
    }

    res.bpi.forEach(
      (key, value) {
        if (key == 'USD') {
          latestPriceUSD.value = value.rate;
          historyUSD.addAll({
            updated.value:
                double.tryParse(latestPriceUSD.replaceAll(',', '')) ?? 0
          });
          if (historyUSD.length >= 10) {
            historyUSD.remove(historyUSD.keys.first);
          }
        } else if (key == 'THB') {
          latestPriceTHB.value = value.rate;
          historyTHB.addAll({
            updated.value:
                double.tryParse(latestPriceTHB.replaceAll(',', '')) ?? 0
          });
          if (historyTHB.length >= 10) {
            historyTHB.remove(historyTHB.keys.first);
          }
        } else {}
      },
    );
    prices = currentCurrency.value == 'USD'
        ? historyUSD.entries
            .map((entry) => PriceData(entry.key, entry.value))
            .toList()
        : historyTHB.entries
            .map((entry) => PriceData(entry.key, entry.value))
            .toList();
    bitcoin = res;
    return res;
  }

  updater() async {
    Timer.periodic(Duration(seconds: 30), (Timer t) async {
      await fetch();
    });
  }

  mapIcon(String currency) {
    if (currency == 'THB') {
      return Image.asset(
          width: 40,
          height: 20,
          'icons/currency/THB.png',
          package: 'currency_icons');
    } else if (currency == 'USD') {
      return Image.asset(
          width: 40,
          height: 20,
          'icons/currency/USD.png',
          package: 'currency_icons');
    }
  }

  String formatDate(DateTime datetime) {
    DateTime parsedDateTime = datetime;
    String hr = parsedDateTime.hour.toString().padLeft(2, '0');
    String m = parsedDateTime.minute.toString().padLeft(2, '0');
    String s = parsedDateTime.second.toString().padLeft(2, '0');
    return "$hr:$m.$s";
  }

  String formatNumber(double number) {
    final NumberFormat formatter = NumberFormat.decimalPattern();
    return formatter.format(number);
  }
}
