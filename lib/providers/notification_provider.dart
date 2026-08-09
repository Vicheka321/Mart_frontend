import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppNotification> _notifications = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;

  String? _error;

  int _currentPage = 1;
  int _lastPage = 1;

  // =========================
  // GETTERS
  // =========================

  List<AppNotification> get notifications => _notifications;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  String? get error => _error;

  bool get hasMore => _currentPage < _lastPage;

  int get unreadCount {
    return _notifications.where((item) => !item.isRead).length;
  }

  // =========================
  // FETCH
  // =========================

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _lastPage = 1;
      _notifications.clear();
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final data = await _apiService.getNotifications(page: 1);

      final page = NotificationPage.fromJson(data);

      _notifications = page.items;
      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // LOAD MORE
  // =========================

  Future<void> loadMore() async {
    if (_isLoadingMore) return;

    if (!hasMore) return;

    _isLoadingMore = true;

    notifyListeners();

    try {
      final nextPage = _currentPage + 1;

      final data = await _apiService.getNotifications(page: nextPage);

      final page = NotificationPage.fromJson(data);

      _notifications.addAll(page.items);

      _currentPage = page.currentPage;
      _lastPage = page.lastPage;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // =========================
  // MARK ONE AS READ
  // =========================

  Future<void> markAsRead(int id) async {
    try {
      final success = await _apiService.markNotificationAsRead(id);

      if (!success) return;

      final index = _notifications.indexWhere((item) => item.id == id);

      if (index == -1) return;

      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      notifyListeners();
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<void> markAllAsRead() async {
    try {
      final success = await _apiService.markAllNotificationsAsRead();

      if (!success) return;

      final now = DateTime.now();

      _notifications = _notifications.map((item) {
        if (item.isRead) {
          return item;
        }

        return item.copyWith(isRead: true, readAt: item.readAt ?? now);
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');

      notifyListeners();
    }
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =========================
  // CLEAR
  // =========================

  void clear() {
    _notifications.clear();

    _currentPage = 1;
    _lastPage = 1;

    _error = null;

    notifyListeners();
  }
}
