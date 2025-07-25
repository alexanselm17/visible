// To parse this JSON data, do
//
//     final userReport = userReportFromJson(jsonString);

import 'dart:convert';

UserReport userReportFromJson(String str) =>
    UserReport.fromJson(json.decode(str));

String userReportToJson(UserReport data) => json.encode(data.toJson());

class UserReport {
  String? message;
  Data? data;
  Pagination? pagination;

  UserReport({
    this.message,
    this.data,
    this.pagination,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) => UserReport(
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
  String? description;
  String? reward;
  DateTime? updatedAt;
  DateTime? validUntil;
  String? imagePath;
  String? imageUrl;
  String? downloadUrl;
  String? videoPath;
  String? videoUrl;
  String? videoDownloadUrl;
  dynamic userScreenshot;
  dynamic screenshotUrl;
  dynamic screenshotId;
  int? screenshotCount;
  List<dynamic>? allScreenshots;

  Datum({
    this.id,
    this.category,
    this.createdAt,
    this.name,
    this.description,
    this.reward,
    this.updatedAt,
    this.validUntil,
    this.imagePath,
    this.imageUrl,
    this.downloadUrl,
    this.videoPath,
    this.videoUrl,
    this.videoDownloadUrl,
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
        description: json["description"],
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
        videoPath: json["video_path"],
        videoUrl: json["video_url"],
        videoDownloadUrl: json["video_download_url"],
        userScreenshot: json["user_screenshot"],
        screenshotUrl: json["screenshot_url"],
        screenshotId: json["screenshot_id"],
        screenshotCount: json["screenshot_count"],
        allScreenshots: json["all_screenshots"] == null
            ? []
            : List<dynamic>.from(json["all_screenshots"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "created_at": createdAt?.toIso8601String(),
        "name": name,
        "description": description,
        "reward": reward,
        "updated_at": updatedAt?.toIso8601String(),
        "valid_until": validUntil?.toIso8601String(),
        "image_path": imagePath,
        "image_url": imageUrl,
        "download_url": downloadUrl,
        "video_path": videoPath,
        "video_url": videoUrl,
        "video_download_url": videoDownloadUrl,
        "user_screenshot": userScreenshot,
        "screenshot_url": screenshotUrl,
        "screenshot_id": screenshotId,
        "screenshot_count": screenshotCount,
        "all_screenshots": allScreenshots == null
            ? []
            : List<dynamic>.from(allScreenshots!.map((x) => x)),
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
