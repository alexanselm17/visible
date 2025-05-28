import 'dart:convert';

UserDashboardModel userDashboardModelFromJson(String str) =>
    UserDashboardModel.fromJson(json.decode(str));

String userDashboardModelToJson(UserDashboardModel data) =>
    json.encode(data.toJson());

class UserDashboardModel {
  bool? success;
  String? message;
  UserDashboardModelData? data;

  UserDashboardModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) =>
      UserDashboardModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : UserDashboardModelData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class UserDashboardModelData {
  int? totalRewards;
  int? totalCampaigns;
  TodayRewards? todayRewards;
  dynamic pendingBalance;
  Achievements? achievements;
  List<RecentReward>? recentRewards;
  Ongoing? ongoing;

  UserDashboardModelData({
    this.totalRewards,
    this.totalCampaigns,
    this.todayRewards,
    this.pendingBalance,
    this.achievements,
    this.recentRewards,
    this.ongoing,
  });

  factory UserDashboardModelData.fromJson(Map<String, dynamic> json) =>
      UserDashboardModelData(
        totalRewards: json["total_rewards"],
        totalCampaigns: json["total_campaigns"],
        todayRewards: json["today_rewards"] == null
            ? null
            : TodayRewards.fromJson(json["today_rewards"]),
        pendingBalance: json["pending_balance"],
        achievements: json["achievements"] == null
            ? null
            : Achievements.fromJson(json["achievements"]),
        recentRewards: json["recent_rewards"] == null
            ? []
            : List<RecentReward>.from(
                json["recent_rewards"]!.map((x) => RecentReward.fromJson(x))),
        ongoing:
            json["ongoing"] == null ? null : Ongoing.fromJson(json["ongoing"]),
      );

  Map<String, dynamic> toJson() => {
        "total_rewards": totalRewards,
        "total_campaigns": totalCampaigns,
        "today_rewards": todayRewards?.toJson(),
        "pending_balance": pendingBalance,
        "achievements": achievements?.toJson(),
        "recent_rewards": recentRewards == null
            ? []
            : List<dynamic>.from(recentRewards!.map((x) => x.toJson())),
        "ongoing": ongoing?.toJson(),
      };
}

class Achievements {
  Daily? daily;
  Daily? weekly;
  Daily? monthly;

  Achievements({
    this.daily,
    this.weekly,
    this.monthly,
  });

  factory Achievements.fromJson(Map<String, dynamic> json) => Achievements(
        daily: json["daily"] == null ? null : Daily.fromJson(json["daily"]),
        weekly: json["weekly"] == null ? null : Daily.fromJson(json["weekly"]),
        monthly:
            json["monthly"] == null ? null : Daily.fromJson(json["monthly"]),
      );

  Map<String, dynamic> toJson() => {
        "daily": daily?.toJson(),
        "weekly": weekly?.toJson(),
        "monthly": monthly?.toJson(),
      };
}

class Daily {
  int? created;
  int? completed;

  Daily({
    this.created,
    this.completed,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => Daily(
        created: json["created"],
        completed: json["completed"],
      );

  Map<String, dynamic> toJson() => {
        "created": created,
        "completed": completed,
      };
}

class Ongoing {
  String? message;
  OngoingData? data;
  Pagination? pagination;

  Ongoing({
    this.message,
    this.data,
    this.pagination,
  });

  factory Ongoing.fromJson(Map<String, dynamic> json) => Ongoing(
        message: json["message"],
        data: json["data"] == null ? null : OngoingData.fromJson(json["data"]),
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

class OngoingData {
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

  OngoingData({
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

  factory OngoingData.fromJson(Map<String, dynamic> json) => OngoingData(
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

class RecentReward {
  int? id;
  String? type;
  String? amount;
  String? advertId;
  String? processedBy;
  String? customerBalance;
  dynamic invoiceNote;
  String? postedBy;
  dynamic banking;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? advertName;

  RecentReward({
    this.id,
    this.type,
    this.amount,
    this.advertId,
    this.processedBy,
    this.customerBalance,
    this.invoiceNote,
    this.postedBy,
    this.banking,
    this.createdAt,
    this.updatedAt,
    this.advertName,
  });

  factory RecentReward.fromJson(Map<String, dynamic> json) => RecentReward(
        id: json["id"],
        type: json["type"],
        amount: json["amount"],
        advertId: json["advert_id"],
        processedBy: json["processed_by"],
        customerBalance: json["customer_balance"],
        invoiceNote: json["invoice_note"],
        postedBy: json["posted_by"],
        banking: json["banking"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        advertName: json["advert_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "amount": amount,
        "advert_id": advertId,
        "processed_by": processedBy,
        "customer_balance": customerBalance,
        "invoice_note": invoiceNote,
        "posted_by": postedBy,
        "banking": banking,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "advert_name": advertName,
      };
}

class TodayRewards {
  int? count;
  int? amount;

  TodayRewards({
    this.count,
    this.amount,
  });

  factory TodayRewards.fromJson(Map<String, dynamic> json) => TodayRewards(
        count: json["count"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "amount": amount,
      };
}
