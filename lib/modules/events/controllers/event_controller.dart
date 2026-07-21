// ═══════════════════════════════════════════════════════════════════════════
// CONTROLLER: EventController - Web Panel Event Management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/role_permission_service.dart';

class EventController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final RolePermissionService _permService = Get.find<RolePermissionService>();

  final isLoading = false.obs;
  final events = <EventModel>[].obs;
  final selectedEvent = Rxn<EventModel>();
  final activeTab = 'events'.obs;

  // Welcome Week
  final welcomeWeekTasks = <Map<String, dynamic>>[].obs;
  final isLoadingWelcomeWeek = false.obs;

  // Festival
  final festivalGifts = <Map<String, dynamic>>[].obs;
  final selectedFestivalType = 'DIWALI'.obs;
  final isLoadingFestival = false.obs;

  // Anniversary
  final anniversaryRewards = <Map<String, dynamic>>[].obs;
  final selectedAnniversaryYear = 1.obs;
  final isLoadingAnniversary = false.obs;

  // Prize Pool
  final prizePool = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  // ═════════════════════════════════════════════════════════════════════
  // EVENT MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════
  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('/events/admin/list');
      if (response['success'] == true) {
        final eventsList = response['data'] as List<dynamic>? ?? [];
        events.assignAll(eventsList.map((e) => EventModel.fromJson(e)).toList());
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    try {
      isLoading.value = true;
      final response = await _apiService.post('/events/admin/create', eventData);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Event created successfully', backgroundColor: Colors.green);
        await loadEvents();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      final response = await _apiService.put('/events/admin/$eventId', updates);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Event updated successfully', backgroundColor: Colors.green);
        await loadEvents();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.delete('/events/admin/$eventId');
      if (response['success'] == true) {
        Get.snackbar('Success', 'Event deleted successfully', backgroundColor: Colors.green);
        await loadEvents();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleEventStatus(String eventId, bool currentStatus) async {
    try {
      await _apiService.put('/events/admin/$eventId', {'is_active': !currentStatus});
      Get.snackbar(
        'Success',
        'Event ${!currentStatus ? 'activated' : 'deactivated'}',
        backgroundColor: Colors.green,
      );
      await loadEvents();
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle event status', backgroundColor: Colors.red);
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // WELCOME WEEK MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════
  Future<void> loadWelcomeWeekTasks() async {
    try {
      isLoadingWelcomeWeek.value = true;
      final response = await _apiService.get('/events/admin/welcome-week/tasks');
      if (response['success'] == true) {
        welcomeWeekTasks.assignAll(response['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load welcome week tasks', backgroundColor: Colors.red);
    } finally {
      isLoadingWelcomeWeek.value = false;
    }
  }

  Future<void> createWelcomeWeekTask(Map<String, dynamic> taskData) async {
    try {
      isLoadingWelcomeWeek.value = true;
      final response = await _apiService.post('/events/admin/welcome-week/tasks', taskData);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Task created successfully', backgroundColor: Colors.green);
        await loadWelcomeWeekTasks();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoadingWelcomeWeek.value = false;
    }
  }

  Future<void> updateWelcomeWeekTask(String taskId, Map<String, dynamic> updates) async {
    try {
      isLoadingWelcomeWeek.value = true;
      final response = await _apiService.put('/events/admin/welcome-week/tasks/$taskId', updates);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Task updated successfully', backgroundColor: Colors.green);
        await loadWelcomeWeekTasks();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update task: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoadingWelcomeWeek.value = false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // FESTIVAL GIFTS MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════
  Future<void> loadFestivalGifts({String? festivalType}) async {
    try {
      isLoadingFestival.value = true;
      final queryParams = festivalType != null ? {'festival_type': festivalType} : <String, String>{};
      final response = await _apiService.get('/events/admin/festival/gifts', queryParams: queryParams);
      if (response['success'] == true) {
        festivalGifts.assignAll(response['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load festival gifts', backgroundColor: Colors.red);
    } finally {
      isLoadingFestival.value = false;
    }
  }

  Future<void> createFestivalGift(Map<String, dynamic> giftData) async {
    try {
      isLoadingFestival.value = true;
      final response = await _apiService.post('/events/admin/festival/gifts', giftData);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Festival gift created successfully', backgroundColor: Colors.green);
        await loadFestivalGifts(festivalType: selectedFestivalType.value);
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create gift: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoadingFestival.value = false;
    }
  }

  Future<void> injectFestivalGifts(String eventId, List<String> giftIds) async {
    try {
      isLoading.value = true;
      final response = await _apiService.post('/events/admin/$eventId/inject-gifts', {
        'giftIds': giftIds,
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Festival gifts injected successfully', backgroundColor: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to inject gifts: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // ANNIVERSARY REWARDS MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════
  Future<void> loadAnniversaryRewards({int? year}) async {
    try {
      isLoadingAnniversary.value = true;
      final queryParams = year != null ? {'year_anniversary': year.toString()} : <String, String>{};
      final response = await _apiService.get('/events/admin/anniversary/rewards', queryParams: queryParams);
      if (response['success'] == true) {
        anniversaryRewards.assignAll(response['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load anniversary rewards', backgroundColor: Colors.red);
    } finally {
      isLoadingAnniversary.value = false;
    }
  }

  Future<void> createAnniversaryReward(Map<String, dynamic> rewardData) async {
    try {
      isLoadingAnniversary.value = true;
      final response = await _apiService.post('/events/admin/anniversary/rewards', rewardData);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Anniversary reward created successfully', backgroundColor: Colors.green);
        await loadAnniversaryRewards(year: selectedAnniversaryYear.value);
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create reward: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoadingAnniversary.value = false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // PRIZE POOL MANAGEMENT
  // ═════════════════════════════════════════════════════════════════════
  Future<void> loadPrizePool(String eventId) async {
    try {
      final response = await _apiService.get('/events/$eventId/prize-pool');
      if (response['success'] == true) {
        prizePool.value = response['data'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load prize pool', backgroundColor: Colors.red);
    }
  }

  Future<void> updatePrizePool(String eventId, Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      final response = await _apiService.patch('/events/admin/$eventId/prize-pool', updates);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Prize pool updated successfully', backgroundColor: Colors.green);
        await loadPrizePool(eventId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update prize pool: ${e.toString()}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // EVENT STATS
  // ═════════════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getEventStats() async {
    try {
      final response = await _apiService.get('/events/admin/stats');
      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load event stats', backgroundColor: Colors.red);
      return null;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═════════════════════════════════════════════════════════════════════
  bool get canCreateEvents => _permService.hasPermission('events.create');
  bool get canEditEvents => _permService.hasPermission('events.edit');
  bool get canDeleteEvents => _permService.hasPermission('events.delete');

  List<EventModel> get activeEvents => events.where((e) => e.isActiveEvent).toList();
  List<EventModel> get upcomingEvents => events.where((e) => e.isUpcoming).toList();
  List<EventModel> get completedEvents => events.where((e) => e.isCompleted).toList();

  void changeTab(String tab) {
    activeTab.value = tab;
    if (tab == 'events') {
      loadEvents();
    } else if (tab == 'welcome_week') {
      loadWelcomeWeekTasks();
    } else if (tab == 'festival') {
      loadFestivalGifts(festivalType: selectedFestivalType.value);
    } else if (tab == 'anniversary') {
      loadAnniversaryRewards(year: selectedAnniversaryYear.value);
    }
  }
}