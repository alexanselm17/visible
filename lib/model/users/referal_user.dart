// To parse this JSON data, do
//
//     final refaralUserModel = refaralUserModelFromJson(jsonString);

import 'dart:convert';

RefaralUserModel refaralUserModelFromJson(String str) =>
    RefaralUserModel.fromJson(json.decode(str));

String refaralUserModelToJson(RefaralUserModel data) =>
    json.encode(data.toJson());

class RefaralUserModel {
  bool? ok;
  String? status;
  String? message;
  User? user;
  Referrals? referrals;

  RefaralUserModel({
    this.ok,
    this.status,
    this.message,
    this.user,
    this.referrals,
  });

  factory RefaralUserModel.fromJson(Map<String, dynamic> json) =>
      RefaralUserModel(
        ok: json["ok"],
        status: json["status"],
        message: json["message"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        referrals: json["referrals"] == null
            ? null
            : Referrals.fromJson(json["referrals"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "status": status,
        "message": message,
        "user": user?.toJson(),
        "referrals": referrals?.toJson(),
      };
}

class Referrals {
  int? currentPage;
  List<Datum>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Referrals({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Referrals.fromJson(Map<String, dynamic> json) => Referrals(
        currentPage: json["current_page"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: json["links"] == null
            ? []
            : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": links == null
            ? []
            : List<dynamic>.from(links!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class Datum {
  String? id;
  String? fullname;
  String? username;
  String? email;
  String? phone;
  String? countyId;
  String? subcountyId;
  String? occupation;
  String? gender;
  int? isLoggedIn;
  int? isActive;
  String? roleId;
  String? referalCode;
  String? myCode;
  String? fcmToken;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Datum({
    this.id,
    this.fullname,
    this.username,
    this.email,
    this.phone,
    this.countyId,
    this.subcountyId,
    this.occupation,
    this.gender,
    this.isLoggedIn,
    this.isActive,
    this.roleId,
    this.referalCode,
    this.myCode,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        fullname: json["fullname"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        countyId: json["county_id"],
        subcountyId: json["subcounty_id"],
        occupation: json["occupation"],
        gender: json["gender"],
        isLoggedIn: json["is_logged_in"],
        isActive: json["is_active"],
        roleId: json["role_id"],
        referalCode: json["referal_code"],
        myCode: json["my_code"],
        fcmToken: json["fcm_token"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "username": username,
        "email": email,
        "phone": phone,
        "county_id": countyId,
        "subcounty_id": subcountyId,
        "occupation": occupation,
        "gender": gender,
        "is_logged_in": isLoggedIn,
        "is_active": isActive,
        "role_id": roleId,
        "referal_code": referalCode,
        "my_code": myCode,
        "fcm_token": fcmToken,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

class User {
  String? id;
  String? fullname;
  String? myCode;

  User({
    this.id,
    this.fullname,
    this.myCode,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fullname: json["fullname"],
        myCode: json["my_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "my_code": myCode,
      };
}
