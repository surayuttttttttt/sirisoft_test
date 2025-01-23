import 'dart:convert';

Bitcoin bitcoinFromJson(String str) => Bitcoin.fromJson(json.decode(str));

String bitcoinToJson(Bitcoin data) => json.encode(data.toJson());

class PriceData {
  PriceData(this.time, this.prices);
  final DateTime time;
  final double prices;
}

class Bitcoin {
  Time time;
  String disclaimer;
  Map<String, Bpi> bpi;

  Bitcoin({
    required this.time,
    required this.disclaimer,
    required this.bpi,
  });

  factory Bitcoin.fromJson(Map<String, dynamic> json) => Bitcoin(
        time: Time.fromJson(json["time"]),
        disclaimer: json["disclaimer"],
        bpi: Map.from(json["bpi"])
            .map((k, v) => MapEntry<String, Bpi>(k, Bpi.fromJson(v))),
      );

  Map<String, dynamic> toJson() => {
        "time": time.toJson(),
        "disclaimer": disclaimer,
        "bpi": Map.from(bpi)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
      };
}

class Bpi {
  String code;
  String rate;
  String description;
  double rateFloat;

  Bpi({
    required this.code,
    required this.rate,
    required this.description,
    required this.rateFloat,
  });

  factory Bpi.fromJson(Map<String, dynamic> json) => Bpi(
        code: json["code"],
        rate: json["rate"],
        description: json["description"],
        rateFloat: json["rate_float"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "rate": rate,
        "description": description,
        "rate_float": rateFloat,
      };
}

class Time {
  String updated;
  DateTime updatedIso;
  String updateduk;

  Time({
    required this.updated,
    required this.updatedIso,
    required this.updateduk,
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
        updated: json["updated"],
        updatedIso: DateTime.parse(json["updatedISO"]),
        updateduk: json["updateduk"],
      );

  Map<String, dynamic> toJson() => {
        "updated": updated,
        "updatedISO": updatedIso.toIso8601String(),
        "updateduk": updateduk,
      };
}
