import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InAppInvitationDialog extends StatelessWidget {
  final String roleName;       // जैसे: SUPER.COIN.SELLER.UID
  final String invitedBy;      // जैसे: Owner / System
  final List<String> grantedPrivileges; // जो-जो परमिशन ओनर ने टिक की हैं

  const InAppInvitationDialog({
    super.key,
    required this.roleName,
    required this.invitedBy,
    required this.grantedPrivileges,
  });

  /// इस डायलॉग को ऐप में कहीं भी शो करने का स्टेटिक फंक्शन
  static void show({
    required String role,
    required String by,
    required List<String> privileges,
  }) {
    Get.dialog(
      InAppInvitationDialog(
        roleName: role,
        invitedBy: by,
        grantedPrivileges: privileges,
      ),
      barrierDismissible: false, // यूजर बिना एक्शन लिए इसे बाहर क्लिक करके नहीं हटा सकता
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E2E), // ऐप की डार्क थीम
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // शीर्ष पर ऑफिशियल बैज आइकन
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user, color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 20),

            // इनविटेशन हेडिंग
            const Text(
              "Official Management Invite",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            Text(
              "You have been invited by $invitedBy to take an official platform responsibility.",
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // अलॉटेड रोल का हाइलाइट बॉक्स
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14141F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text("ASSIGNED ROLE", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    roleName,
                    style: const TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // दी गई परमिशंस की लिस्ट (Privileges Preview)
            alignmentLeft(context, "Granted Key Permissions:"),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: Column(
                  children: grantedPrivileges.map((privilege) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              privilege,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // एक्शन बटन्स (Accept / Decline)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      foregroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Decline"),
                    onPressed: () {
                      // रिजेक्ट करने पर बैकएंड को स्टेटस अपडेट भेजेंगे
                      Get.back();
                      Get.snackbar("Invitation Declined", "You have rejected the management role offer.",
                          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Accept", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Get.back();
                      // यहाँ गेटएक्स स्टेट अपडेट होगा और यूजर की प्रोफाइल पर 'Staff Console' का बटन खुल जाएगा
                      Get.snackbar(
                        "Role Activated 🎉",
                        "Congratulations! Your panel access as $roleName is now live.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 4),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget alignmentLeft(BuildContext context, String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}