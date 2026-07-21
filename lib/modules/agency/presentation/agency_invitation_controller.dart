import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/core/services/api_service.dart';

class AgencyInvitationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Text editing controllers
  final uidController = TextEditingController();
  final messageController = TextEditingController();

  // Reactive state variables
  final isLoading = false.obs;
  final invitations = <dynamic>[].obs;
  final pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInbox();
  }

  @override
  void onClose() {
    uidController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> fetchInbox() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/agency/invitations/inbox');
      if (response['success'] == true) {
        invitations.value = List<dynamic>.from(response['data'] ?? []);
        pendingCount.value = response['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Fetch inbox error: $e');
      Get.snackbar('Error', 'Failed to fetch invitation inbox.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendInvitation() async {
    final uid = uidController.text.trim();
    final message = messageController.text.trim();
    if (uid.isEmpty) {
      Get.snackbar('Error', 'Please enter a valid UID');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.post('/agency/invitations/send', {
        'targetUid': uid,
        'message': message,
        'specialRoles': {},
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Invitation sent successfully');
        uidController.clear();
        messageController.clear();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to send invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send invitation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/agency/invitations/accept/$invitationId', {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Invitation accepted! Welcome to the agency.');
        fetchInbox(); // Refresh the inbox
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to accept invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept invitation');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post('/agency/invitations/reject/$invitationId', {});
      if (response['success'] == true) {
        Get.snackbar('Rejected', 'Invitation rejected');
        fetchInbox(); // Refresh the inbox
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to reject invitation');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject invitation');
    } finally {
      isLoading.value = false;
    }
  }
}