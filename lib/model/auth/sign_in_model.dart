// To parse this JSON data, do
//
//     final signInModel = signInModelFromJson(jsonString);

import 'dart:convert';

SignInModel signInModelFromJson(String str) =>
    SignInModel.fromJson(json.decode(str));

String signInModelToJson(SignInModel data) => json.encode(data.toJson());

class SignInModel {
  bool? ok;
  String? status;
  String? message;
  Data? data;
  String? token;
  DateTime? tokenCreatedAt;

  SignInModel({
    this.ok,
    this.status,
    this.message,
    this.data,
    this.token,
    this.tokenCreatedAt,
  });

  factory SignInModel.fromJson(Map<String, dynamic> json) => SignInModel(
        ok: json["ok"],
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        token: json["token"],
        tokenCreatedAt: json["token_created_at"] == null
            ? null
            : DateTime.parse(json["token_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "token": token,
        "token_created_at": tokenCreatedAt?.toIso8601String(),
      };
}

class Data {
  String? id;
  String? fullname;
  String? username;
  String? phone;
  String? email;
  int? isActive;
  String? roleId;
  dynamic isVerified;
  int? nationalId;
  int? isLoggedIn;
  dynamic cardNumber;
  String? occupation;
  String? location;
  String? gender;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  Role? role;

  Data({
    this.id,
    this.fullname,
    this.username,
    this.phone,
    this.email,
    this.isActive,
    this.roleId,
    this.isVerified,
    this.nationalId,
    this.isLoggedIn,
    this.cardNumber,
    this.occupation,
    this.location,
    this.gender,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.role,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        fullname: json["fullname"],
        username: json["username"],
        phone: json["phone"],
        email: json["email"],
        isActive: json["is_active"],
        roleId: json["role_id"],
        isVerified: json["is_verified"],
        nationalId: json["national_id"],
        isLoggedIn: json["is_logged_in"],
        cardNumber: json["card_number"],
        occupation: json["occupation"],
        location: json["location"],
        gender: json["gender"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "username": username,
        "phone": phone,
        "email": email,
        "is_active": isActive,
        "role_id": roleId,
        "is_verified": isVerified,
        "national_id": nationalId,
        "is_logged_in": isLoggedIn,
        "card_number": cardNumber,
        "occupation": occupation,
        "location": location,
        "gender": gender,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
        "role": role?.toJson(),
      };
}

class Role {
  String? id;
  String? name;
  String? slug;

  Role({
    this.id,
    this.name,
    this.slug,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
      };
}
