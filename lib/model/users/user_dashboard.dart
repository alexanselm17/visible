class UserDashboardModel {
  bool? success;
  String? message;
  UserDashboardModelData? data;

  UserDashboardModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserDashboardModel.fromJson(Map<String, dynamic> json) {
    return UserDashboardModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? UserDashboardModelData.fromJson(json['data'])
          : null,
    );
  }
}

class UserDashboardModelData {
  int? totalRewards;
  int? totalCampaigns;
  TodayRewards? todayRewards;
  String? pendingBalance;
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

  factory UserDashboardModelData.fromJson(Map<String, dynamic> json) {
    return UserDashboardModelData(
      totalRewards: json['total_rewards'],
      totalCampaigns: json['total_campaigns'],
      todayRewards: json['today_rewards'] != null
          ? TodayRewards.fromJson(json['today_rewards'])
          : null,
      pendingBalance: json['pending_balance'],
      achievements: json['achievements'] != null
          ? Achievements.fromJson(json['achievements'])
          : null,
      recentRewards: json['recent_rewards'] != null
          ? (json['recent_rewards'] as List)
              .map((e) => RecentReward.fromJson(e))
              .toList()
          : null,
      ongoing:
          json['ongoing'] != null ? Ongoing.fromJson(json['ongoing']) : null,
    );
  }
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

  factory Achievements.fromJson(Map<String, dynamic> json) {
    return Achievements(
      daily: json['daily'] != null ? Daily.fromJson(json['daily']) : null,
      weekly: json['weekly'] != null ? Daily.fromJson(json['weekly']) : null,
      monthly: json['monthly'] != null ? Daily.fromJson(json['monthly']) : null,
    );
  }
}

class Daily {
  int? created;
  int? completed;

  Daily({
    this.created,
    this.completed,
  });

  factory Daily.fromJson(Map<String, dynamic> json) {
    return Daily(
      created: json['created'],
      completed: json['completed'],
    );
  }
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

  factory Ongoing.fromJson(Map<String, dynamic> json) {
    return Ongoing(
      message: json['message'],
      data: json['data'] != null ? OngoingData.fromJson(json['data']) : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class OngoingData {
  int? currentPage;
  List<dynamic>? data;
  String? firstPageUrl;
  dynamic from;
  int? lastPage;
  String? lastPageUrl;
  List<Link>? links;
  dynamic nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  dynamic to;
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

  factory OngoingData.fromJson(Map<String, dynamic> json) {
    return OngoingData(
      currentPage: json['current_page'],
      data: json['data'],
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: json['links'] != null
          ? (json['links'] as List).map((e) => Link.fromJson(e)).toList()
          : null,
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
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

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}

class Pagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  dynamic from;
  dynamic to;

  Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      from: json['from'],
      to: json['to'],
    );
  }
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

  factory RecentReward.fromJson(Map<String, dynamic> json) {
    return RecentReward(
      id: json['id'],
      type: json['type'],
      amount: json['amount'],
      advertId: json['advert_id'],
      processedBy: json['processed_by'],
      customerBalance: json['customer_balance'],
      invoiceNote: json['invoice_note'],
      postedBy: json['posted_by'],
      banking: json['banking'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      advertName: json['advert_name'],
    );
  }
}

class TodayRewards {
  int? count;
  int? amount;

  TodayRewards({
    this.count,
    this.amount,
  });

  factory TodayRewards.fromJson(Map<String, dynamic> json) {
    return TodayRewards(
      count: json['count'],
      amount: json['amount'],
    );
  }
}
