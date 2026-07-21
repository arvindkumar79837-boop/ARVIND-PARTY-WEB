// ═══════════════════════════════════════════════════════════════════════════
// VIEW: EventManagementDashboardView - Master Event Engine Admin Panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class EventManagementDashboardView extends StatelessWidget {
  const EventManagementDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find<EventController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Event Engine'),
        bottom: TabBar(
          onTap: (index) {
            switch (index) {
              case 0:
                controller.changeTab('events');
                break;
              case 1:
                controller.changeTab('welcome_week');
                break;
              case 2:
                controller.changeTab('festival');
                break;
              case 3:
                controller.changeTab('anniversary');
                break;
              case 4:
                controller.changeTab('prize_pool');
                break;
            }
          },
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Welcome Week'),
            Tab(text: 'Festival'),
            Tab(text: 'Anniversary'),
            Tab(text: 'Prize Pools'),
          ],
        ),
      ),
      body: Obx(() {
        switch (controller.activeTab.value) {
          case 'events':
            return _buildEventsTab(context, controller);
          case 'welcome_week':
            return _buildWelcomeWeekTab(context, controller);
          case 'festival':
            return _buildFestivalTab(context, controller);
          case 'anniversary':
            return _buildAnniversaryTab(context, controller);
          case 'prize_pool':
            return _buildPrizePoolTab(context, controller);
          default:
            return _buildEventsTab(context, controller);
        }
      }),
      floatingActionButton: Obx(() {
        if (controller.activeTab.value == 'events' && controller.canCreateEvents) {
          return FloatingActionButton(
            onPressed: () => _showCreateEventDialog(context, controller),
            child: const Icon(Icons.add),
          );
        }
        if (controller.activeTab.value == 'welcome_week' && controller.canCreateEvents) {
          return FloatingActionButton(
            onPressed: () => _showCreateWelcomeWeekTaskDialog(context, controller),
            child: const Icon(Icons.add),
          );
        }
        if (controller.activeTab.value == 'festival' && controller.canCreateEvents) {
          return FloatingActionButton(
            onPressed: () => _showCreateFestivalGiftDialog(context, controller),
            child: const Icon(Icons.add),
          );
        }
        if (controller.activeTab.value == 'anniversary' && controller.canCreateEvents) {
          return FloatingActionButton(
            onPressed: () => _showCreateAnniversaryRewardDialog(context, controller),
            child: const Icon(Icons.add),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildEventsTab(BuildContext context, EventController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final activeEvents = controller.activeEvents;
      final upcomingEvents = controller.upcomingEvents;
      final completedEvents = controller.completedEvents;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeEvents.isNotEmpty) ...[
              const Text('Active Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...activeEvents.map((e) => _buildEventCard(context, controller, e)),
              const SizedBox(height: 24),
            ],
            if (upcomingEvents.isNotEmpty) ...[
              const Text('Upcoming Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...upcomingEvents.map((e) => _buildEventCard(context, controller, e)),
              const SizedBox(height: 24),
            ],
            if (completedEvents.isNotEmpty) ...[
              const Text('Completed Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...completedEvents.map((e) => _buildEventCard(context, controller, e)),
            ],
            if (controller.events.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No events found'))),
          ],
        ),
      );
    });
  }

  Widget _buildEventCard(BuildContext context, EventController controller, EventModel event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: event.isActiveEvent ? Colors.green : event.isUpcoming ? Colors.orange : Colors.grey,
        child: Text(
          event.eventType.substring(0, 2),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type: ${event.eventType}'),
          const SizedBox(height: 4),
          Text('Participants: ${event.participantsCount}/${event.maxParticipants == 0 ? '∞' : event.maxParticipants}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.canEditEvents)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: () => _toggleEventStatus(context, controller, event.id, event.isActive),
            ),
          if (controller.canDeleteEvents)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEvent(context, controller, event.id),
            ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: ${event.description}'),
              const SizedBox(height: 8),
              Text('Start: ${event.startTime.toString().substring(0, 16)}'),
              Text('End: ${event.endTime.toString().substring(0, 16)}'),
              const SizedBox(height: 8),
              Text('Rewards:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  Coins: ${event.rewardCoins}, Diamonds: ${event.rewardDiamonds}, XP: ${event.rewardXp}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _loadPrizePool(context, controller, event.id),
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Manage Prize Pool'),
                  ),
                  const SizedBox(width: 8),
                  if (event.eventType == 'FESTIVAL')
                    ElevatedButton.icon(
                      onPressed: () => _injectGifts(context, controller, event.id),
                      icon: const Icon(Icons.card_giftcard),
                      label: const Text('Inject Gifts'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildWelcomeWeekTab(BuildContext context, EventController controller) {
  return Obx(() {
    if (controller.isLoadingWelcomeWeek.value) {
      return const Center(child: CircularProgressIndicator());
    }

    final tasks = controller.welcomeWeekTasks;

    if (tasks.isEmpty) {
      return const Center(child: Text('No welcome week tasks configured'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text('D${task['day_number']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            title: Text(task['task_name'] ?? 'Task ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['task_description'] ?? ''),
                const SizedBox(height: 4),
                Text('Rewards: ${task['reward_coins'] ?? 0} coins, ${task['reward_diamonds'] ?? 0} diamonds'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit' && controller.canEditEvents) {
                  _showEditWelcomeWeekTaskDialog(context, controller, task);
                } else if (value == 'delete' && controller.canDeleteEvents) {
                  _deleteWelcomeWeekTask(context, controller, task['_id']);
                }
              },
              itemBuilder: (context) => [
                if (controller.canEditEvents)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (controller.canDeleteEvents)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  });
}

Widget _buildFestivalTab(BuildContext context, EventController controller) {
  return Column(
    children: [
      DropdownButton<String>(
        value: controller.selectedFestivalType.value,
        items: const [
          DropdownMenuItem(value: 'DIWALI', child: Text('Diwali')),
          DropdownMenuItem(value: 'EID', child: Text('Eid')),
          DropdownMenuItem(value: 'NEW_YEAR', child: Text('New Year')),
          DropdownMenuItem(value: 'HOLI', child: Text('Holi')),
          DropdownMenuItem(value: 'CHRISTMAS', child: Text('Christmas')),
          DropdownMenuItem(value: 'CUSTOM', child: Text('Custom')),
        ],
        onChanged: (value) {
          if (value != null) {
            controller.selectedFestivalType.value = value;
            controller.loadFestivalGifts(festivalType: value);
          }
        },
      ),
      Expanded(
        child: Obx(() {
          if (controller.isLoadingFestival.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final gifts = controller.festivalGifts;

          if (gifts.isEmpty) {
            return const Center(child: Text('No festival gifts configured'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getFestivalColor(gift['festival_type']),
                    child: const Icon(Icons.card_giftcard, color: Colors.white),
                  ),
                  title: Text(gift['gift_name'] ?? 'Gift ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${gift['gift_id']}'),
                      Text('Rarity: ${gift['metadata']?['rarity'] ?? 'common'}'),
                    ],
                  ),
                  trailing: Icon(gift['is_limited'] == true ? Icons.star : Icons.star_border),
                ),
              );
            },
          );
        }),
      ),
    ],
  );
}

Widget _buildAnniversaryTab(BuildContext context, EventController controller) {
  return Column(
    children: [
      DropdownButton<int>(
        value: controller.selectedAnniversaryYear.value,
        items: List.generate(10, (index) => DropdownMenuItem(value: index + 1, child: Text('Year ${index + 1}'))),
        onChanged: (value) {
          if (value != null) {
            controller.selectedAnniversaryYear.value = value;
            controller.loadAnniversaryRewards(year: value);
          }
        },
      ),
      Expanded(
        child: Obx(() {
          if (controller.isLoadingAnniversary.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final rewards = controller.anniversaryRewards;

          if (rewards.isEmpty) {
            return const Center(child: Text('No anniversary rewards configured'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    child: Text('R${reward['rank_position']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(reward['reward_name'] ?? 'Reward ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category: ${reward['category']}'),
                      Text('Type: ${reward['reward_type']}, Value: ${reward['reward_value']}'),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    ],
  );
}

Widget _buildPrizePoolTab(BuildContext context, EventController controller) {
  return const Center(
    child: Text('Select an event from the Events tab to manage its prize pool'),
  );
}

Future<void> _showCreateEventDialog(BuildContext context, EventController controller) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  String selectedType = 'DAILY_TASK';

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Event Name')),
            const SizedBox(height: 8),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'LOGIN', child: Text('Login Event')),
                DropdownMenuItem(value: 'DAILY_TASK', child: Text('Daily Task')),
                DropdownMenuItem(value: 'RECHARGE', child: Text('Recharge Bonus')),
                DropdownMenuItem(value: 'FESTIVAL', child: Text('Festival')),
                DropdownMenuItem(value: 'ANNIVERSARY', child: Text('Anniversary')),
                DropdownMenuItem(value: 'LUCKY_DRAW', child: Text('Lucky Draw')),
                DropdownMenuItem(value: 'TOURNAMENT', child: Text('Tournament')),
              ],
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) {
              Get.snackbar('Error', 'Event name is required');
              return;
            }
            controller.createEvent({
              'event_name': nameController.text.trim(),
              'event_type': selectedType,
              'description': descriptionController.text.trim(),
              'start_time': DateTime.now().toIso8601String(),
              'end_time': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
            });
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

Future<void> _showCreateWelcomeWeekTaskDialog(BuildContext context, EventController controller) async {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Welcome Week Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Task Name')),
          const SizedBox(height: 8),
          TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.createWelcomeWeekTask({
              'task_name': nameController.text.trim(),
              'task_description': descController.text.trim(),
              'day_number': 1,
              'task_type': 'login',
              'target_count': 1,
              'display_order': 0,
            });
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

Future<void> _showCreateFestivalGiftDialog(BuildContext context, EventController controller) async {
  final nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Festival Gift'),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Gift Name')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.createFestivalGift({
              'gift_name': nameController.text.trim(),
              'festival_name': controller.selectedFestivalType.value,
              'festival_type': controller.selectedFestivalType.value,
              'gift_id': 'GIFT_${DateTime.now().millisecondsSinceEpoch}',
              'available_from': DateTime.now().toIso8601String(),
              'available_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            });
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

Future<void> _showCreateAnniversaryRewardDialog(BuildContext context, EventController controller) async {
  final nameController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Create Anniversary Reward'),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Reward Name')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.createAnniversaryReward({
              'reward_name': nameController.text.trim(),
              'year_anniversary': controller.selectedAnniversaryYear.value,
              'category': 'participation',
              'reward_type': 'badge',
              'reward_value': 0,
            });
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

Future<void> _showEditWelcomeWeekTaskDialog(BuildContext context, EventController controller, Map<String, dynamic> task) async {
  final nameController = TextEditingController(text: task['task_name'] ?? '');

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Task'),
      content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Task Name')),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.updateWelcomeWeekTask(task['_id'], {'task_name': nameController.text.trim()});
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

Future<void> _toggleEventStatus(BuildContext context, EventController controller, String eventId, bool currentStatus) async {
  await controller.toggleEventStatus(eventId, currentStatus);
}

Future<void> _deleteEvent(BuildContext context, EventController controller, String eventId) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Event'),
      content: const Text('Are you sure you want to delete this event?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Get.back(result: true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
      ],
    ),
  );

  if (confirm == true) {
    await controller.deleteEvent(eventId);
  }
}

Future<void> _deleteWelcomeWeekTask(BuildContext context, EventController controller, String taskId) async {
  // Implement delete task
}

Future<void> _loadPrizePool(BuildContext context, EventController controller, String eventId) async {
  await controller.loadPrizePool(eventId);
}

Future<void> _injectGifts(BuildContext context, EventController controller, String eventId) async {
  // Implement inject gifts
}

Color _getFestivalColor(String? festivalType) {
  switch (festivalType) {
    case 'DIWALI':
      return Colors.orange;
    case 'EID':
      return Colors.green;
    case 'NEW_YEAR':
      return Colors.purple;
    case 'HOLI':
      return Colors.pink;
    case 'CHRISTMAS':
      return Colors.red;
    default:
      return Colors.blue;
  }
}
}