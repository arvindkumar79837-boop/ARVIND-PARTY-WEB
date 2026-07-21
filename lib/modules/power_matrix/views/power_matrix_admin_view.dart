// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/power_matrix/views/power_matrix_admin_view.dart
// ARVIND PARTY - POWER MATRIX ADMIN VIEW (Web Panel)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arvind_party_web/modules/power_matrix/controllers/power_matrix_controller.dart';
import 'package:arvind_party_web/modules/power_matrix/models/power_matrix_model.dart';

class PowerMatrixAdminView extends GetView<PowerMatrixController> {
  const PowerMatrixAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Matrix Administration'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchPowerMatrix,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(context),
            tooltip: 'View History',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context),
              const SizedBox(height: 20),
              _buildGlobalSettingsCard(context),
              const SizedBox(height: 20),
              _buildPowerCheckCard(context),
              const SizedBox(height: 20),
              _buildRulesTable(context),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Power Matrix Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Version: ${controller.version.value}'),
                if (controller.powerMatrix.value != null)
                  Text('Last Updated: ${controller.powerMatrix.value!.updatedAt.toString().substring(0, 19)}'),
              ],
            ),
            Switch(
              value: controller.isActive.value,
              onChanged: (value) {
                controller.isActive.value = value;
              },
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSettingsCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Owner Can Override All'),
                Obx(
                  () => Switch(
                    value: controller.globalSettings.value.ownerCanOverrideAll,
                    onChanged: (value) {
                      controller.updateGlobalSettings(
                        PowerMatrixGlobalSettings(
                          ownerCanOverrideAll: value,
                          adminCanOverrideVip: controller.globalSettings.value.adminCanOverrideVip,
                          svipImmunityLevel: controller.globalSettings.value.svipImmunityLevel,
                          vipImmunityLevel: controller.globalSettings.value.vipImmunityLevel,
                          levelDifferenceRequired: controller.globalSettings.value.levelDifferenceRequired,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Admin Can Override VIP'),
                Obx(
                  () => Switch(
                    value: controller.globalSettings.value.adminCanOverrideVip,
                    onChanged: (value) {
                      controller.updateGlobalSettings(
                        PowerMatrixGlobalSettings(
                          ownerCanOverrideAll: controller.globalSettings.value.ownerCanOverrideAll,
                          adminCanOverrideVip: value,
                          svipImmunityLevel: controller.globalSettings.value.svipImmunityLevel,
                          vipImmunityLevel: controller.globalSettings.value.vipImmunityLevel,
                          levelDifferenceRequired: controller.globalSettings.value.levelDifferenceRequired,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('SVIP Immunity Level:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<int>(
                    value: controller.globalSettings.value.svipImmunityLevel,
                    items: List.generate(20, (index) => index + 1)
                        .map((level) => DropdownMenuItem(value: level, child: Text('$level')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateGlobalSettings(
                          PowerMatrixGlobalSettings(
                            ownerCanOverrideAll: controller.globalSettings.value.ownerCanOverrideAll,
                            adminCanOverrideVip: controller.globalSettings.value.adminCanOverrideVip,
                            svipImmunityLevel: value,
                            vipImmunityLevel: controller.globalSettings.value.vipImmunityLevel,
                            levelDifferenceRequired: controller.globalSettings.value.levelDifferenceRequired,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 32),
                const Text('VIP Immunity Level:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<int>(
                    value: controller.globalSettings.value.vipImmunityLevel,
                    items: List.generate(20, (index) => index + 1)
                        .map((level) => DropdownMenuItem(value: level, child: Text('$level')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateGlobalSettings(
                          PowerMatrixGlobalSettings(
                            ownerCanOverrideAll: controller.globalSettings.value.ownerCanOverrideAll,
                            adminCanOverrideVip: controller.globalSettings.value.adminCanOverrideVip,
                            svipImmunityLevel: controller.globalSettings.value.svipImmunityLevel,
                            vipImmunityLevel: value,
                            levelDifferenceRequired: controller.globalSettings.value.levelDifferenceRequired,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Level Difference Required:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Obx(
                  () => DropdownButton<int>(
                    value: controller.globalSettings.value.levelDifferenceRequired,
                    items: List.generate(5, (index) => index + 1)
                        .map((diff) => DropdownMenuItem(value: diff, child: Text('$diff')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateGlobalSettings(
                          PowerMatrixGlobalSettings(
                            ownerCanOverrideAll: controller.globalSettings.value.ownerCanOverrideAll,
                            adminCanOverrideVip: controller.globalSettings.value.adminCanOverrideVip,
                            svipImmunityLevel: controller.globalSettings.value.svipImmunityLevel,
                            vipImmunityLevel: controller.globalSettings.value.vipImmunityLevel,
                            levelDifferenceRequired: value,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerCheckCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Power Check Simulator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Target User ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) => controller.checkTargetUserId.value = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: controller.checkAction.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mute', child: Text('Mute')),
                        DropdownMenuItem(value: 'kick', child: Text('Kick')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.checkAction.value = value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => controller.checkUserPower(
                    controller.checkTargetUserId.value,
                    controller.checkAction.value,
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: const Text('Check'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () {
                final result = controller.lastCheckResult.value;
                if (result != null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: controller.getPowerCheckColor(result).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: controller.getPowerCheckColor(result)),
                    ),
                    child: Text(
                      controller.getPowerCheckDescription(result),
                      style: TextStyle(
                        color: controller.getPowerCheckColor(result),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTable(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Level Rules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Total Rules: ${controller.rules.length}'),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Level')),
                  DataColumn(label: Text('Can Mute')),
                  DataColumn(label: Text('Can Kick')),
                  DataColumn(label: Text('Mute Threshold')),
                  DataColumn(label: Text('Kick Threshold')),
                ],
                rows: controller.rules.map((rule) {
                  return DataRow(
                    cells: [
                      DataCell(Text('${rule.level}')),
                      DataCell(
                        Switch(
                          value: rule.canMuteLowerLevels,
                          onChanged: (value) {
                            controller.updateRule(
                              PowerMatrixRule(
                                level: rule.level,
                                canMuteLowerLevels: value,
                                canKickLowerLevels: rule.canKickLowerLevels,
                                muteLevelThreshold: rule.muteLevelThreshold,
                                kickLevelThreshold: rule.kickLevelThreshold,
                                vipProtectionLevel: rule.vipProtectionLevel,
                                specialPrivileges: rule.specialPrivileges,
                              ),
                            );
                          },
                        ),
                      ),
                      DataCell(
                        Switch(
                          value: rule.canKickLowerLevels,
                          onChanged: (value) {
                            controller.updateRule(
                              PowerMatrixRule(
                                level: rule.level,
                                canMuteLowerLevels: rule.canMuteLowerLevels,
                                canKickLowerLevels: value,
                                muteLevelThreshold: rule.muteLevelThreshold,
                                kickLevelThreshold: rule.kickLevelThreshold,
                                vipProtectionLevel: rule.vipProtectionLevel,
                                specialPrivileges: rule.specialPrivileges,
                              ),
                            );
                          },
                        ),
                      ),
                      DataCell(
                        DropdownButton<int>(
                          value: rule.muteLevelThreshold,
                          items: List.generate(50, (index) => index)
                              .map((threshold) => DropdownMenuItem(
                                    value: threshold,
                                    child: Text('$threshold'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateRule(
                                PowerMatrixRule(
                                  level: rule.level,
                                  canMuteLowerLevels: rule.canMuteLowerLevels,
                                  canKickLowerLevels: rule.canKickLowerLevels,
                                  muteLevelThreshold: value,
                                  kickLevelThreshold: rule.kickLevelThreshold,
                                  vipProtectionLevel: rule.vipProtectionLevel,
                                  specialPrivileges: rule.specialPrivileges,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      DataCell(
                        DropdownButton<int>(
                          value: rule.kickLevelThreshold,
                          items: List.generate(50, (index) => index)
                              .map((threshold) => DropdownMenuItem(
                                    value: threshold,
                                    child: Text('$threshold'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.updateRule(
                                PowerMatrixRule(
                                  level: rule.level,
                                  canMuteLowerLevels: rule.canMuteLowerLevels,
                                  canKickLowerLevels: rule.canKickLowerLevels,
                                  muteLevelThreshold: rule.muteLevelThreshold,
                                  kickLevelThreshold: value,
                                  vipProtectionLevel: rule.vipProtectionLevel,
                                  specialPrivileges: rule.specialPrivileges,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final confirm = await Get.dialog(
              AlertDialog(
                title: const Text('Reset Power Matrix'),
                content: const Text('Are you sure you want to reset all settings to default?'),
                actions: [
                  TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
            if (confirm == true || confirm == null) {
              await controller.resetPowerMatrix();
            }
          },
          icon: const Icon(Icons.restore),
          label: const Text('Reset to Default'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () async {
            await controller.updatePowerMatrix();
          },
          icon: const Icon(Icons.save),
          label: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
      ],
    );
  }

  void _showHistoryDialog(BuildContext context) {
    controller.fetchHistory();
    Get.dialog(
      Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Power Matrix History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoadingHistory.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: controller.history.length,
                      itemBuilder: (context, index) {
                        final item = controller.history[index];
                        return ListTile(
                          title: Text('Version ${item.version}'),
                          subtitle: Text('Updated: ${item.updatedAt.toString().substring(0, 19)}\nBy: ${item.updatedBy ?? "System"}'),
                          trailing: Icon(
                            item.isActive ? Icons.check_circle : Icons.cancel,
                            color: item.isActive ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}