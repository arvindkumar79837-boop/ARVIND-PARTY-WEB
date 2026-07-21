import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../models/revenue_summary.dart';
import '../models/user_analytics.dart';
import '../models/live_analytics.dart';
import '../models/gift_analytics.dart';

class AnalyticsService {
  final ApiService _api = Get.find<ApiService>();

  Future<RevenueSummary> getRevenueSummary() async {
    try {
      final response = await _api.get('/analytics/revenue/summary');
      if (response['success'] == true && response['data'] != null) {
        return RevenueSummary.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to load revenue summary');
      }
    } catch (e) {
      debugPrint('Error fetching revenue summary: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRechargeAnalytics({int page = 1, int limit = 10, String? userId, String? coinSellerId, String? startDate, String? endDate}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (userId != null) params['userId'] = userId;
    if (coinSellerId != null) params['coinSellerId'] = coinSellerId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final response = await _api.get('/analytics/revenue/recharges', queryParams: params);
    return response;
  }

  Future<Map<String, dynamic>> getWithdrawalAnalytics({int page = 1, int limit = 10, String? status, String? agencyId, String? startDate, String? endDate}) async {
    final params = <String, String>{'page': '$page', 'limit': '$limit'};
    if (status != null) params['status'] = status;
    if (agencyId != null) params['agencyId'] = agencyId;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    final response = await _api.get('/analytics/revenue/withdrawals', queryParams: params);
    return response;
  }

  Future<UserAnalytics> getUserAnalytics() async {
    try {
      final response = await _api.get('/analytics/engagement/users');
      if (response['success'] == true && response['data'] != null) {
        return UserAnalytics.fromJson(response['data']);
      }
      throw Exception('Failed to load user analytics');
    } catch (e) {
      debugPrint('Error fetching user analytics: $e');
      rethrow;
    }
  }

  Future<LiveAnalytics> getLiveAnalytics() async {
    try {
      final response = await _api.get('/analytics/engagement/live');
      if (response['success'] == true && response['data'] != null) {
        return LiveAnalytics.fromJson(response['data']);
      }
      throw Exception('Failed to load live analytics');
    } catch (e) {
      debugPrint('Error fetching live analytics: $e');
      rethrow;
    }
  }

  Future<GiftAnalytics> getGiftAnalytics() async {
    try {
      final response = await _api.get('/analytics/engagement/gifts');
      if (response['success'] == true && response['data'] != null) {
        return GiftAnalytics.fromJson(response['data']);
      }
      throw Exception('Failed to load gift analytics');
    } catch (e) {
      debugPrint('Error fetching gift analytics: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAgencyAnalytics({int limit = 20}) async {
    try {
      final response = await _api.get('/analytics/performance/agencies', queryParams: {'limit': '$limit'});
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      throw Exception('Failed to load agency analytics');
    } catch (e) {
      debugPrint('Error fetching agency analytics: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getFamilyAnalytics({int limit = 20}) async {
    try {
      final response = await _api.get('/analytics/performance/families', queryParams: {'limit': '$limit'});
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      throw Exception('Failed to load family analytics');
    } catch (e) {
      debugPrint('Error fetching family analytics: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLiveChartData() async {
    try {
      final response = await _api.get('/analytics/charts/live');
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load chart data');
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getHeatMapData({String? country, String? date}) async {
    try {
      final params = <String, String>{};
      if (country != null) params['country'] = country;
      if (date != null) params['date'] = date;
      final response = await _api.get('/analytics/charts/heatmap', queryParams: params);
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      throw Exception('Failed to load heat map data');
    } catch (e) {
      debugPrint('Error fetching heat map data: $e');
      rethrow;
    }
  }

  Future<void> triggerRevenueSummaryUpdate() async {
    await _api.post('/analytics/revenue/update-summary', {});
  }

  Future<void> triggerDailyAggregation() async {
    await _api.post('/analytics/aggregate/daily', {});
  }
}