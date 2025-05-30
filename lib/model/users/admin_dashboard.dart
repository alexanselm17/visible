// To parse this JSON data, do
//
//     final adminModel = adminModelFromJson(jsonString);

import 'dart:convert';

AdminModel adminModelFromJson(String str) =>
    AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  bool? success;
  String? message;
  Data? data;

  AdminModel({
    this.success,
    this.message,
    this.data,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  int? campaignsCreated;
  int? rewardsAssigned;
  int? completed;
  int? ongoing;
  int? unusedSlots;
  int? paymentDone;
  int? pendingPayment;
  int? totalUsers;
  List<TopCampaign>? topCampaigns;

  Data({
    this.campaignsCreated,
    this.rewardsAssigned,
    this.completed,
    this.ongoing,
    this.unusedSlots,
    this.paymentDone,
    this.pendingPayment,
    this.totalUsers,
    this.topCampaigns,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        campaignsCreated: json["campaigns_created"],
        rewardsAssigned: json["rewards_assigned"],
        completed: json["completed"],
        ongoing: json["ongoing"],
        unusedSlots: json["unused_slots"],
        paymentDone: json["payment_done"],
        pendingPayment: json["pending_payment"],
        totalUsers: json["total_users"],
        topCampaigns: json["top_campaigns"] == null
            ? []
            : List<TopCampaign>.from(
                json["top_campaigns"]!.map((x) => TopCampaign.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "campaigns_created": campaignsCreated,
        "rewards_assigned": rewardsAssigned,
        "completed": completed,
        "ongoing": ongoing,
        "unused_slots": unusedSlots,
        "payment_done": paymentDone,
        "pending_payment": pendingPayment,
        "total_users": totalUsers,
        "top_campaigns": topCampaigns == null
            ? []
            : List<dynamic>.from(topCampaigns!.map((x) => x.toJson())),
      };
}

class TopCampaign {
  String? id;
  String? name;
  int? completed;
  int? capacity;
  int? rewardTotal;

  TopCampaign({
    this.id,
    this.name,
    this.completed,
    this.capacity,
    this.rewardTotal,
  });

  factory TopCampaign.fromJson(Map<String, dynamic> json) => TopCampaign(
        id: json["id"],
        name: json["name"],
        completed: json["completed"],
        capacity: json["capacity"],
        rewardTotal: json["reward_total"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "completed": completed,
        "capacity": capacity,
        "reward_total": rewardTotal,
      };
}
