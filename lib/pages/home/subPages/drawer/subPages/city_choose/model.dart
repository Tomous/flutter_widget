// To parse this JSON data, do
//
//     final cityModel = cityModelFromJson(jsonString);

import 'dart:convert';

List<CityModel> cityModelFromJson(String str) =>
    List<CityModel>.from(json.decode(str).map((x) => CityModel.fromJson(x)));

String cityModelToJson(List<CityModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CityModel {
  String? name; //城市名称
  String? pinyin; //城市拼音
  String? indexLetter; //首字母

  CityModel({
    this.name,
    this.pinyin,
    this.indexLetter,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        name: json["name"],
        pinyin: json["pinyin"],
        indexLetter: json["indexLetter"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "pinyin": pinyin,
        "indexLetter": indexLetter,
      };
}
