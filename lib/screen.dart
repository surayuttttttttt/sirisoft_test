import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirisoft_test/ui_helper.dart';
import 'package:sirisoft_test/controller.dart';
import 'package:sirisoft_test/model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  BitCoinController bitCoinController = Get.put(BitCoinController());
  CustomTextStyle customTextStyle = CustomTextStyle();
  @override
  void initState() {
    bitCoinController.updater();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 230, 240),
      appBar: AppBar(
        title: Text(
          'Bitcoin Price Tracker',
          style: customTextStyle.textStyle.copyWith(fontSize: 24),
        ),
      ),
      body: FutureBuilder<Bitcoin?>(
        future: bitCoinController.fetch(),
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              snapshot.connectionState == ConnectionState.none) {
            return buildErrorWidget();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingWidget();
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return buildDataWidget();
          }
          return buildErrorWidget();
        },
      ),
    );
  }

  Widget buildTopWidget() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: 125,
            maxHeight: 150,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                          height: 45,
                          width: 45,
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/2048px-Bitcoin.svg.png'),
                      Divider(
                        indent: 8,
                      ),
                      Text(
                        'Bitcoin',
                        style: customTextStyle.textStyle
                            .copyWith(fontSize: 24, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                  Obx(
                    () => DropdownButton<String>(
                      value: bitCoinController.currentCurrency.value,
                      onChanged: (String? newValue) {
                        bitCoinController.currentCurrency.value =
                            newValue ?? 'USD';
                        bitCoinController.fetch();
                      },
                      items: <String>['THB', 'USD']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              bitCoinController.mapIcon(value),
                              Text(
                                '    $value',
                                style: customTextStyle.textStyle,
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                        bitCoinController.currentCurrency.value == 'USD'
                            ? '${bitCoinController.latestPriceUSD} \$'
                            : '${bitCoinController.latestPriceTHB} ฿',
                        style: customTextStyle.textStyle.copyWith(
                            color: const Color.fromARGB(255, 29, 137, 253),
                            fontSize: 50)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChartWidget() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: GetBuilder<BitCoinController>(
        builder: (context) => SizedBox(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: const Color.fromARGB(255, 255, 255, 255),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => SfCartesianChart(
                  title: ChartTitle(
                    alignment: ChartAlignment.near,
                    textStyle: customTextStyle.textStyle.copyWith(fontSize: 14),
                    text:
                        'Latest Updated on : ${bitCoinController.formatDate(bitCoinController.updated.value)}',
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    header: '',
                    format:
                        'point.x : point.y ${bitCoinController.currentCurrency.value == 'USD' ? "\$" : "฿"}',
                    canShowMarker: true,
                    color: Colors.blue,
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  primaryYAxis: NumericAxis(
                    axisLabelFormatter: (AxisLabelRenderDetails details) {
                      return ChartAxisLabel(
                          bitCoinController
                              .formatNumber((details.value).toDouble()),
                          customTextStyle.textStyle);
                    },
                    opposedPosition: true,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                    plotBands: <PlotBand>[
                      PlotBand(
                        start: bitCoinController.currentCurrency.value == 'USD'
                            ? bitCoinController.historyUSD.values.last
                            : bitCoinController.historyTHB.values.last,
                        end: bitCoinController.currentCurrency.value == 'USD'
                            ? bitCoinController.historyUSD.values.last
                            : bitCoinController.historyTHB.values.last,
                        borderWidth: 2,
                        borderColor: Colors.orangeAccent,
                        dashArray: const <double>[
                          4,
                          5,
                        ],
                      )
                    ],
                    axisLine: AxisLine(color: Colors.red),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                  ),
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.minutes,
                    dateFormat: DateFormat.Hms(),
                    autoScrollingMode: AutoScrollingMode.end,
                    labelPosition: ChartDataLabelPosition.outside,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  series: <CartesianSeries>[
                    LineSeries<PriceData, DateTime>(
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        shape: DataMarkerType.circle,
                        borderColor: Colors.blue,
                        borderWidth: 2,
                        color: Colors.blue,
                        width: 10,
                        height: 10,
                      ),
                      dataLabelMapper: (PriceData data, int index) {
                        if (index == bitCoinController.prices.length - 1) {
                          return bitCoinController.formatNumber(data.prices);
                        }
                        return '';
                      },
                      dataLabelSettings: DataLabelSettings(
                          borderColor: Colors.amber,
                          color: Colors.amber,
                          labelAlignment: ChartDataLabelAlignment.top,
                          textStyle: customTextStyle.textStyle
                              .copyWith(color: Colors.black),
                          isVisible: true),
                      dataSource: bitCoinController.prices,
                      xValueMapper: (PriceData data, _) => data.time,
                      yValueMapper: (PriceData data, _) {
                        return data.prices;
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHistory() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Price updated history',
                style: customTextStyle.textStyle.copyWith(fontSize: 14),
              ),
              Obx(() => Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView(
                        shrinkWrap: true,
                        children: bitCoinController.currentCurrency == 'THB'
                            ? bitCoinController.historyTHB.entries
                                .toList()
                                .reversed
                                .map(
                                (entry) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${bitCoinController.formatDate(entry.key)}: ${bitCoinController.formatNumber(entry.value)} \$',
                                      style: customTextStyle.textStyle.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ).toList()
                            : bitCoinController.historyUSD.entries
                                .toList()
                                .reversed
                                .map(
                                (entry) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${bitCoinController.formatDate(entry.key)}: ${bitCoinController.formatNumber(entry.value)} \$',
                                      style: customTextStyle.textStyle.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 150,
          ),
          Text(
            'Something went wrong',
            style: customTextStyle.textStyle.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildDataWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: [buildTopWidget(), buildChartWidget(), buildHistory()],
      ),
    );
  }
}
