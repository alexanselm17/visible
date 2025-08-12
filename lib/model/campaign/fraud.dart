// To parse this JSON data, do
//
//     final fraudUserModel = fraudUserModelFromJson(jsonString);

import 'dart:convert';

FraudUserModel fraudUserModelFromJson(String str) =>
    FraudUserModel.fromJson(json.decode(str));

String fraudUserModelToJson(FraudUserModel data) => json.encode(data.toJson());

class FraudUserModel {
  List<FraudGroup>? fraudGroups;

  FraudUserModel({
    this.fraudGroups,
  });

  factory FraudUserModel.fromJson(Map<String, dynamic> json) => FraudUserModel(
        fraudGroups: json["fraud_groups"] == null
            ? []
            : List<FraudGroup>.from(
                json["fraud_groups"]!.map((x) => FraudGroup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "fraud_groups": fraudGroups == null
            ? []
            : List<dynamic>.from(fraudGroups!.map((x) => x.toJson())),
      };
}

class FraudGroup {
  String? advertId;
  String? matchingViewsTimestamp;
  List<String>? users;
  List<Detail>? details;

  FraudGroup({
    this.advertId,
    this.matchingViewsTimestamp,
    this.users,
    this.details,
  });

  factory FraudGroup.fromJson(Map<String, dynamic> json) => FraudGroup(
        advertId: json["advert_id"],
        matchingViewsTimestamp: json["matching_views_timestamp"],
        users: json["users"] == null
            ? []
            : List<String>.from(json["users"]!.map((x) => x)),
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "advert_id": advertId,
        "matching_views_timestamp": matchingViewsTimestamp,
        "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x)),
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  String? userId;
  String? name;
  int? views;
  String? timestamp;
  int? number;
  String? url;

  Detail({
    this.userId,
    this.name,
    this.views,
    this.timestamp,
    this.number,
    this.url,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        userId: json["user_id"],
        name: json["name"],
        views: json["views"],
        timestamp: json["timestamp"],
        number: json["number"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "views": views,
        "timestamp": timestamp,
        "number": number,
        "url": url,
      };
}
