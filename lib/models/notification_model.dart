// lib/models/notification_model.dart
//
// Maps to the Laravel `NotificationUser` (pivot/wrapper) + its `notification`
// relation, as returned by:
//   GET /api/notifications  -> paginated NotificationUser::with('notification')
//
// Adjust field names below if your `notifications` table columns differ
// (e.g. if you use `message` instead of `body`, or `data` as a JSON blob).

class AppNotification {
  final int id; // NotificationUser id (used for /notifications/{id}/read)
  final int? notificationId;
  final String title;
  final String body;
  final String? type; // e.g. "order", "promo", "system"
  final String? imageUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // optional payload for deep-linking

  AppNotification({
    required this.id,
    this.notificationId,
    required this.title,
    required this.body,
    this.type,
    this.imageUrl,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final notif = json['notification'] as Map<String, dynamic>?;

    DateTime? tryParse(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AppNotification(
      id: json['id'] as int,
      notificationId: notif?['id'] as int?,
      title: (notif?['title'] ?? json['title'] ?? 'Notification').toString(),
      body: (notif?['body'] ??
              notif?['message'] ??
              json['body'] ??
              json['message'] ??
              '')
          .toString(),
      type: (notif?['type'] ?? json['type'])?.toString(),
      imageUrl: (notif?['image'] ?? notif?['image_url'] ?? json['image'])
          ?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1,
      readAt: tryParse(json['read_at']),
      createdAt: tryParse(json['created_at']) ?? DateTime.now(),
      data: notif?['data'] is Map<String, dynamic>
          ? notif!['data'] as Map<String, dynamic>
          : null,
    );
  }

  AppNotification copyWith({bool? isRead, DateTime? readAt}) {
    return AppNotification(
      id: id,
      notificationId: notificationId,
      title: title,
      body: body,
      type: type,
      imageUrl: imageUrl,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      data: data,
    );
  }
}

/// Thin wrapper around Laravel's default paginate() JSON shape:
/// { data: [...], current_page, last_page, next_page_url, total, ... }
class NotificationPage {
  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  NotificationPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();

    final currentPage = json['current_page'] as int? ?? 1;
    final lastPage = json['last_page'] as int? ?? 1;

    return NotificationPage(
      items: data,
      currentPage: currentPage,
      lastPage: lastPage,
      hasMore: currentPage < lastPage,
    );
  }
}