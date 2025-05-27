// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  String? message;
  Data? data;
  Pagination? pagination;

  ProductModel({
    this.message,
    this.data,
    this.pagination,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "pagination": pagination?.toJson(),
      };
}

class Data {
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

  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
  String? category;
  DateTime? createdAt;
  String? name;
  int? reward;
  DateTime? updatedAt;
  DateTime? validUntil;
  String? imagePath;
  String? imageUrl;
  String? downloadUrl;
  String? userScreenshot;
  String? screenshotUrl;
  String? screenshotId;
  int? screenshotCount;
  List<AllScreenshot>? allScreenshots;

  Datum({
    this.id,
    this.category,
    this.createdAt,
    this.name,
    this.reward,
    this.updatedAt,
    this.validUntil,
    this.imagePath,
    this.imageUrl,
    this.downloadUrl,
    this.userScreenshot,
    this.screenshotUrl,
    this.screenshotId,
    this.screenshotCount,
    this.allScreenshots,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        category: json["category"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        name: json["name"],
        reward: json["reward"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        validUntil: json["valid_until"] == null
            ? null
            : DateTime.parse(json["valid_until"]),
        imagePath: json["image_path"],
        imageUrl: json["image_url"],
        downloadUrl: json["download_url"],
        userScreenshot: json["user_screenshot"],
        screenshotUrl: json["screenshot_url"],
        screenshotId: json["screenshot_id"],
        screenshotCount: json["screenshot_count"],
        allScreenshots: json["all_screenshots"] == null
            ? []
            : List<AllScreenshot>.from(
                json["all_screenshots"]!.map((x) => AllScreenshot.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "created_at": createdAt?.toIso8601String(),
        "name": name,
        "reward": reward,
        "updated_at": updatedAt?.toIso8601String(),
        "valid_until": validUntil?.toIso8601String(),
        "image_path": imagePath,
        "image_url": imageUrl,
        "download_url": downloadUrl,
        "user_screenshot": userScreenshot,
        "screenshot_url": screenshotUrl,
        "screenshot_id": screenshotId,
        "screenshot_count": screenshotCount,
        "all_screenshots": allScreenshots == null
            ? []
            : List<dynamic>.from(allScreenshots!.map((x) => x.toJson())),
      };
}

class AllScreenshot {
  int? views;

  AllScreenshot({
    this.views,
  });

  factory AllScreenshot.fromJson(Map<String, dynamic> json) => AllScreenshot(
        views: json["views"],
      );

  Map<String, dynamic> toJson() => {
        "views": views,
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

class Pagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        lastPage: json["last_page"],
        from: json["from"],
        to: json["to"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "per_page": perPage,
        "current_page": currentPage,
        "last_page": lastPage,
        "from": from,
        "to": to,
      };
}
