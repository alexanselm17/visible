// To parse this JSON data, do
//
//     final campaignModel = campaignModelFromJson(jsonString);

import 'dart:convert';

CampaignModel campaignModelFromJson(String str) =>
    CampaignModel.fromJson(json.decode(str));

String campaignModelToJson(CampaignModel data) => json.encode(data.toJson());

class CampaignModel {
  bool? ok;
  String? message;
  List<Datum>? data;

  CampaignModel({
    this.ok,
    this.message,
    this.data,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        ok: json["ok"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  String? name;
  String? capitalInvested;
  DateTime? validUntil;
  String? reward;
  int? capacity;
  int? completed;
  int? ongoing;
  int? available;
  int? totalRewardsGiven;
  DateTime? createdAt;

  Datum({
    this.id,
    this.name,
    this.capitalInvested,
    this.validUntil,
    this.reward,
    this.capacity,
    this.completed,
    this.ongoing,
    this.available,
    this.totalRewardsGiven,
    this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        capitalInvested: json["capital_invested"],
        validUntil: json["valid_until"] == null
            ? null
            : DateTime.parse(json["valid_until"]),
        reward: json["reward"],
        capacity: json["capacity"],
        completed: json["completed"],
        ongoing: json["ongoing"],
        available: json["available"],
        totalRewardsGiven: json["total_rewards_given"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "capital_invested": capitalInvested,
        "valid_until": validUntil?.toIso8601String(),
        "reward": reward,
        "capacity": capacity,
        "completed": completed,
        "ongoing": ongoing,
        "available": available,
        "total_rewards_given": totalRewardsGiven,
        "created_at": createdAt?.toIso8601String(),
      };
}
