import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/role_auth_controller.dart';
import '../../auth/models/role_permission_model.dart';

class CoinGeneratorView extends StatefulWidget {
  const CoinGeneratorView({super.key});

  @override
  State<CoinGeneratorView> createState() => _CoinGeneratorViewState();
}

class _CoinGeneratorViewState extends State<CoinGeneratorView> {
  final RoleAuthController authController = Get.find<RoleAuthController>();

  // टेक्स्ट फ़ील्ड्स को कंट्रोल करने के लिए
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sellerUidController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // डमी स्टेट (दिखाने के लिए कि प्लेटफॉर्म पर अभी कुल कितने कॉइन्स ओनर के पास स्टॉक में हैं)
  int totalMintedVaultCoins = 5000000; 

  @override
  Widget build(BuildContext context) {
    // एक्स्ट्रा प्रोटेक्शन: अगर गलती से ओनर के अलावा कोई इस रूट पर आ जाए
    if (authController.currentUserRole.value != RoleType.ownerWeb) {
      return const Scaffold(
        backgroundColor: Color(0xFF14141F),
        body: Center(
          child: Text(
            "CRITICAL ERROR: Access Denied. Only the Platform Owner can access the Coin Vault.",
            style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // डीप डार्क थीम
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // हेडर टाइटल
                  const Text(
                    "Master Coin Vault & Generation",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mint global application coins and distribute bulk supplies exclusively to authorized Coin Sellers.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // लाइव वॉल्ट बैलेंस कार्ड (Vault Balance Overview)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE65100), Color(0xFFFF9800)], // ओनर का सिग्नेचर ऑरेंज ग्लो
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CURRENT OWNER VAULT BALANCE",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.white, size: 36),
                                const SizedBox(width: 8),
                                Text(
                                totalMintedVaultCoins.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                                ),
                                const SizedBox(width: 8),
                                const Text("COINS", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(50)),
                          child: const Icon(Icons.security, color: Colors.white, size: 40),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // दो मुख्य ब्लॉक्स: एक तरफ सिक्का बनाना, दूसरी तरफ सेलर को ट्रांसफर करना
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ब्लॉक 1: मिंट/जनरेट कॉइन
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2D2D44)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.add_box, color: Colors.green, size: 24),
                                  SizedBox(width: 8),
                                  Text("Mint / Generate Coins", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),
                              
                              _buildTextField(
                                label: "Coin Quantity to Mint",
                                hint: "e.g., 1000000",
                                controller: amountController,
                                icon: Icons.toll,
                              ),
                              const SizedBox(height: 24),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Mint Coins Into Vault", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  onPressed: () {
                                    if (amountController.text.isEmpty) return;
                                    int mintedAmount = int.parse(amountController.text);
                                    setState(() {
                                      totalMintedVaultCoins += mintedAmount;
                                    });
                                    Get.snackbar(
                                      "Coins Minted Successfully",
                                      "$mintedAmount Coins generated secure-log inside your private Owner vault.",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      maxWidth: 450,
                                    );
                                    amountController.clear();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // ब्लॉक 2: कॉइन सेलर को ट्रांसफर करना (Dispatch Control)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2D2D44)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.local_shipping, color: Colors.orange, size: 24),
                                  SizedBox(width: 8),
                                  Text("Dispatch to Authorized Coin Seller", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),
                              
                              _buildTextField(
                                label: "Target Coin Seller UID",
                                hint: "Enter seller unique ID (e.g., 883921)",
                                controller: sellerUidController,
                                icon: Icons.account_circle,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                label: "Transfer Coin Amount",
                                hint: "Quantity to allocate...",
                                controller: transferAmountController,
                                icon: Icons.send_and_archive,
                              ),
                              const SizedBox(height: 24),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Authorize Bulk Dispatch", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  onPressed: () {
                                    if (sellerUidController.text.isEmpty || transferAmountController.text.isEmpty) return;
                                    int transferVal = int.parse(transferAmountController.text);
                                    
                                    if (transferVal > totalMintedVaultCoins) {
                                      Get.snackbar("Vault Underflow", "You do not have enough coins minted in vault to complete this transfer.",
                                          backgroundColor: Colors.redAccent, colorText: Colors.white, maxWidth: 450);
                                      return;
                                    }

                                    setState(() {
                                      totalMintedVaultCoins -= transferVal;
                                    });

                                    Get.dialog(
                                      AlertDialog(
                                        backgroundColor: const Color(0xFF1E1E2E),
                                        title: const Text("Allocation Transferred", style: TextStyle(color: Colors.green)),
                                        content: Text("$transferVal Coins have been instantly dispatched to Coin Seller UID ${sellerUidController.text}."),
                                        actions: [
                                          TextButton(
                                            child: const Text("Done", style: TextStyle(color: Colors.orange)),
                                            onPressed: () {
                                              Get.back();
                                              sellerUidController.clear();
                                              transferAmountController.clear();
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // टेक्स्ट फ़ील्ड बनाने का हेल्पर विजेट
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange, size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF14141F),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3D3D5C))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange)),
          ),
        ),
      ],
    );
  }
}