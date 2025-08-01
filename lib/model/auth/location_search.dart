// To parse this JSON data, do
//
//     final locationSearch = locationSearchFromJson(jsonString);

import 'dart:convert';

LocationSearch locationSearchFromJson(String str) => LocationSearch.fromJson(json.decode(str));

String locationSearchToJson(LocationSearch data) => json.encode(data.toJson());

class LocationSearch {
    bool? ok;
    String? status;
    List<Datum>? data;

    LocationSearch({
        this.ok,
        this.status,
        this.data,
    });

    factory LocationSearch.fromJson(Map<String, dynamic> json) => LocationSearch(
        ok: json["ok"],
        status: json["status"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? name;
    dynamic capital;
    int? code;
    DateTime? createdAt;
    DateTime? updatedAt;
    List<SubCounty>? subCounties;

    Datum({
        this.id,
        this.name,
        this.capital,
        this.code,
        this.createdAt,
        this.updatedAt,
        this.subCounties,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        capital: json["capital"],
        code: json["code"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        subCounties: json["sub_counties"] == null ? [] : List<SubCounty>.from(json["sub_counties"]!.map((x) => SubCounty.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "capital": capital,
        "code": code,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "sub_counties": subCounties == null ? [] : List<dynamic>.from(subCounties!.map((x) => x.toJson())),
    };
}

class SubCounty {
    String? id;
    String? name;
    String? countyId;
    DateTime? createdAt;
    DateTime? updatedAt;

    SubCounty({
        this.id,
        this.name,
        this.countyId,
        this.createdAt,
        this.updatedAt,
    });

    factory SubCounty.fromJson(Map<String, dynamic> json) => SubCounty(
        id: json["id"],
        name: json["name"],
        countyId: json["county_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "county_id": countyId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
