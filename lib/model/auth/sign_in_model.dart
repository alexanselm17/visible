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
  Role? role;

  Data({
    this.id,
    this.fullname,
    this.username,
    this.phone,
    this.role,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        fullname: json["fullname"],
        username: json["username"],
        phone: json["phone"],
        role: json["role"] == null ? null : Role.fromJson(json["role"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "username": username,
        "phone": phone,
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
