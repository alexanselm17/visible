// To parse this JSON data, do
//
//     final userNotifications = userNotificationsFromJson(jsonString);

import 'dart:convert';

UserNotifications userNotificationsFromJson(String str) =>
    UserNotifications.fromJson(json.decode(str));

String userNotificationsToJson(UserNotifications data) =>
    json.encode(data.toJson());

class UserNotifications {
  List<Notification>? notifications;
  Pagination? pagination;
  int? unreadCount;

  UserNotifications({
    this.notifications,
    this.pagination,
    this.unreadCount,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) =>
      UserNotifications(
        notifications: json["notifications"] == null
            ? []
            : List<Notification>.from(
                json["notifications"]!.map((x) => Notification.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
        unreadCount: json["unread_count"],
      );

  Map<String, dynamic> toJson() => {
        "notifications": notifications == null
            ? []
            : List<dynamic>.from(notifications!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
        "unread_count": unreadCount,
      };
}

class Notification {
  String? id;
  String? userId;
  String? title;
  String? message;
  String? type;
  bool? isRead;
  dynamic data;
  DateTime? readAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  Notification({
    this.id,
    this.userId,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.data,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        userId: json["user_id"],
        title: json["title"],
        message: json["message"],
        type: json["type"],
        isRead: json["is_read"],
        data: json["data"],
        readAt:
            json["read_at"] == null ? null : DateTime.parse(json["read_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "message": message,
        "type": type,
        "is_read": isRead,
        "data": data,
        "read_at": readAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  bool? hasMore;

  Pagination({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["current_page"],
        lastPage: json["last_page"],
        perPage: json["per_page"],
        total: json["total"],
        hasMore: json["has_more"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "last_page": lastPage,
        "per_page": perPage,
        "total": total,
        "has_more": hasMore,
      };
}
