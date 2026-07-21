import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/analytics_service.dart';
import '../models/revenue_summary.dart';
import '../models/user_analytics.dart';
import '../models/live_analytics.dart';
import '../models/gift_analytics.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/services/api_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();
  final ApiService _apiService = Get.find<ApiService>();

  // --- Loading States ---
  var isLoading = true.obs;
  var isLoadingRevenue = false.obs;
  var isLoadingEngagement = false.obs;
  var isLoadingDepartmental = false.obs;
  var isLoadingCharts = false.obs;

  // --- Feature 28: Revenue ---
  var revenueSummary = Rx<RevenueSummary?>(null);
  var rechargeResults = RxList<Map<String, dynamic>>();
  var rechargeRevenuePerSeller = RxList<Map<String, dynamic>>();
  var withdrawalResults = RxList<Map<String, dynamic>>();
  var withdrawalPendingStats = Rxn<Map<String, dynamic>>();

  // --- Feature 29: Engagement ---
  var userAnalytics = Rx<UserAnalytics?>(null);
  var liveAnalytics = Rx<LiveAnalytics?>(null);
  var giftAnalytics = Rx<GiftAnalytics?>(null);

  // --- Feature 30: Departmental ---
  var agencyRankings = RxList<Map<String, dynamic>>();
  var familyRankings = RxList<Map<String, dynamic>>();

  // --- Feature 31: Charts ---
  var chartData = Rxn<Map<String, dynamic>>();
  var heatMapData = RxList<Map<String, dynamic>>();

  // --- Pagination ---
  var rechargePage = 1.obs;
  var rechargeTotalPages = 1.obs;
  var withdrawalPage = 1.obs;
  var withdrawalTotalPages = 1.obs;

  // --- Socket ---
  IO.Socket? socket;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    setupSocket();
  }

  @override
  void onClose() {
    disposeSocket();
    super.onClose();
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading(true);
      final results = await Future.wait([
        _analyticsService.getRevenueSummary(),
        _analyticsService.getUserAnalytics(),
        _analyticsService.getLiveAnalytics(),
        _analyticsService.getGiftAnalytics(),
        _analyticsService.getAgencyAnalytics(),
        _analyticsService.getFamilyAnalytics(),
        _analyticsService.getLiveChartData(),
        _analyticsService.getHeatMapData(),
      ]);
      revenueSummary(results[0] as RevenueSummary);
      userAnalytics(results[1] as UserAnalytics);
      liveAnalytics(results[2] as LiveAnalytics);
      giftAnalytics(results[3] as GiftAnalytics);
      agencyRankings.assignAll((results[4] as List<dynamic>).cast<Map<String, dynamic>>());
      familyRankings.assignAll((results[5] as List<dynamic>).cast<Map<String, dynamic>>());
      chartData(results[6] as Map<String, dynamic>?);
      heatMapData.assignAll((results[7] as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error fetching initial analytics data: $e');
    } finally {
      isLoading(false);
    }
  }

  void setupSocket() {
    final token = _apiService.token;
    if (token == null) {
      debugPrint('No auth token found, analytics socket connection aborted.');
      return;
    }

    try {
      socket = IO.io(
        '${EnvConfig.socketUrl}/analytics',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      socket!.onConnect((_) {
        debugPrint('Analytics Socket: Connected to /analytics namespace');
      });

      socket!.on('initial_data', (dynamic data) {
        if (data == null) return;
        final Map<String, dynamic> map = data as Map<String, dynamic>;
        if (map['revenueSummary'] != null) {
          revenueSummary(RevenueSummary.fromJson(map['revenueSummary']));
        }
        if (map['userAnalytics'] != null) {
          userAnalytics(UserAnalytics.fromJson(map['userAnalytics']));
        }
        if (map['liveAnalytics'] != null) {
          liveAnalytics(LiveAnalytics.fromJson(map['liveAnalytics']));
        }
        if (map['chartData'] != null) {
          chartData(map['chartData'] as Map<String, dynamic>?);
        }
      });

      socket!.on('revenue_summary_updated', (dynamic data) {
        if (data != null) {
          revenueSummary(RevenueSummary.fromJson(data));
        }
      });

      socket!.on('live_analytics_updated', (dynamic data) {
        if (data != null) {
          liveAnalytics(LiveAnalytics.fromJson(data));
        }
      });

      socket!.on('chart_data_updated', (dynamic data) {
        if (data != null) {
          chartData(data as Map<String, dynamic>?);
        }
      });

      socket!.on('gift_analytics_updated', (dynamic data) {
        if (data != null) {
          giftAnalytics(GiftAnalytics.fromJson(data));
        }
      });

      socket!.on('agency_analytics_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          agencyRankings.assignAll(list.cast<Map<String, dynamic>>());
        }
      });

      socket!.on('family_analytics_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          familyRankings.assignAll(list.cast<Map<String, dynamic>>());
        }
      });

      socket!.on('heatmap_data_updated', (dynamic data) {
        if (data != null) {
          final List<dynamic> list = data as List<dynamic>;
          heatMapData.assignAll(list.cast<Map<String, dynamic>>());
        }
      });

      socket!.on('daily_aggregation_complete', (dynamic data) {
        debugPrint('Daily aggregation completed: $data');
      });

      socket!.onDisconnect((_) => debugPrint('Analytics Socket: Disconnected'));
      socket!.onError((error) => debugPrint('Analytics Socket Error: $error'));

    } catch (e) {
      debugPrint('Error setting up analytics socket: $e');
    }
  }

  void disposeSocket() {
    socket?.dispose();
  }

  // ─── Feature 28: Revenue Actions ─────────────────────────

  Future<void> fetchRevenueSummary() async {
    try {
      isLoadingRevenue(true);
      final summary = await _analyticsService.getRevenueSummary();
      revenueSummary(summary);
    } catch (e) {
      debugPrint('Error fetching revenue summary: $e');
    } finally {
      isLoadingRevenue(false);
    }
  }

  Future<void> fetchRechargeAnalytics({int page = 1}) async {
    try {
      isLoadingRevenue(true);
      rechargePage(page);
      final result = await _analyticsService.getRechargeAnalytics(page: page);
      final results = result['results'];
      if (results != null) {
        rechargeResults.assignAll((results as List<dynamic>).cast<Map<String, dynamic>>());
      }
      final revenuePerSeller = result['revenuePerSeller'];
      if (revenuePerSeller != null) {
        rechargeRevenuePerSeller.assignAll((revenuePerSeller as List<dynamic>).cast<Map<String, dynamic>>());
      }
      final totalPages = result['totalPages'];
      if (totalPages != null) {
        rechargeTotalPages(totalPages as int);
      }
    } catch (e) {
      debugPrint('Error fetching recharge analytics: $e');
    } finally {
      isLoadingRevenue(false);
    }
  }

  Future<void> fetchWithdrawalAnalytics({int page = 1, String? status}) async {
    try {
      isLoadingRevenue(true);
      withdrawalPage(page);
      final result = await _analyticsService.getWithdrawalAnalytics(page: page, status: status);
      final results = result['results'];
      if (results != null) {
        withdrawalResults.assignAll((results as List<dynamic>).cast<Map<String, dynamic>>());
      }
      final pendingStats = result['pendingStats'];
      if (pendingStats != null) {
        withdrawalPendingStats(pendingStats as Map<String, dynamic>?);
      }
      final totalPages = result['totalPages'];
      if (totalPages != null) {
        withdrawalTotalPages(totalPages as int);
      }
    } catch (e) {
      debugPrint('Error fetching withdrawal analytics: $e');
    } finally {
      isLoadingRevenue(false);
    }
  }

  Future<void> triggerRevenueSummaryUpdate() async {
    await _analyticsService.triggerRevenueSummaryUpdate();
    socket?.emit('request_revenue_update');
  }

  // ─── Feature 29: Engagement Actions ──────────────────────

  Future<void> fetchEngagementData() async {
    try {
      isLoadingEngagement(true);
      final results = await Future.wait([
        _analyticsService.getUserAnalytics(),
        _analyticsService.getLiveAnalytics(),
        _analyticsService.getGiftAnalytics(),
      ]);
      userAnalytics(results[0] as UserAnalytics);
      liveAnalytics(results[1] as LiveAnalytics);
      giftAnalytics(results[2] as GiftAnalytics);
    } catch (e) {
      debugPrint('Error fetching engagement data: $e');
    } finally {
      isLoadingEngagement(false);
    }
  }

  // ─── Feature 30: Departmental Actions ────────────────────

  Future<void> fetchDepartmentalData() async {
    try {
      isLoadingDepartmental(true);
      final results = await Future.wait([
        _analyticsService.getAgencyAnalytics(),
        _analyticsService.getFamilyAnalytics(),
      ]);
      agencyRankings.assignAll((results[0]).cast<Map<String, dynamic>>());
      familyRankings.assignAll((results[1]).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error fetching departmental data: $e');
    } finally {
      isLoadingDepartmental(false);
    }
  }

  // ─── Feature 31: Chart Actions ───────────────────────────

  Future<void> fetchChartData() async {
    try {
      isLoadingCharts(true);
      final results = await Future.wait([
        _analyticsService.getLiveChartData(),
        _analyticsService.getHeatMapData(),
      ]);
      chartData(results[0] as Map<String, dynamic>?);
      heatMapData.assignAll((results[1] as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
    } finally {
      isLoadingCharts(false);
    }
  }

  // ─── Refresh All ─────────────────────────────────────────

  Future<void> refreshAll() async {
    await fetchInitialData();
    socket?.emit('request_revenue_update');
    socket?.emit('request_live_update');
    socket?.emit('request_chart_update');
    socket?.emit('request_gift_update');
    socket?.emit('request_agency_update');
    socket?.emit('request_family_update');
    socket?.emit('request_heatmap_update');
  }

  Future<void> triggerDailyAggregation() async {
    await _analyticsService.triggerDailyAggregation();
  }
}