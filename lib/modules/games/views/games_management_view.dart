import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/webview_game_model.dart';

class GamesManagementView extends GetView<GameController> {
  const GamesManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Games Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddGameDialog(context),
            icon: const Icon(Icons.add, color: Colors.orange),
            tooltip: 'Add New Game',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(child: _buildGamesList(context)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[850],
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: controller.selectedGameType.value,
                decoration: InputDecoration(
                  labelText: 'Game Type',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                dropdownColor: Colors.grey[800],
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Types')),
                  DropdownMenuItem(value: 'RENTED', child: Text('Rented/Third-Party')),
                  DropdownMenuItem(value: 'IN_HOUSE', child: Text('In-House')),
                  DropdownMenuItem(value: 'WEB_BASED', child: Text('Web-Based')),
                ],
                onChanged: (value) => controller.filterByGameType(value),
              );
            }),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => controller.fetchAllGames(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.orange),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingGames.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.orange));
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.fetchAllGames(),
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.orange)),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (controller.games.isEmpty) {
        return const Center(
          child: Text('No games found', style: TextStyle(color: Colors.grey, fontSize: 16)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.games.length,
        itemBuilder: (context, index) {
          final game = controller.games[index];
          return _buildGameCard(context, game);
        },
      );
    });
  }

  Widget _buildGameCard(BuildContext context, WebViewGameModel game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(game.thumbnailUrl.isNotEmpty
                  ? game.thumbnailUrl
                  : 'https://via.placeholder.com/60'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          game.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${game.gameType}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Bet: ${game.minBetAmount} - ${game.maxBetAmount} coins',
              style: TextStyle(color: Colors.orange[300], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Plays: ${game.totalPlays} | Volume: ${game.totalVolume}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditGameDialog(context, game),
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: () => _confirmDeleteGame(context, game.id, game.name),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              tooltip: 'Delete',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddGameDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final descController = TextEditingController();
    final minBetController = TextEditingController(text: '10');
    final maxBetController = TextEditingController(text: '10000');
    final coinRatioController = TextEditingController(text: '100');
    final diamondRatioController = TextEditingController(text: '0.01');
    String selectedType = 'RENTED';
    String selectedReward = 'COINS';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Game', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[850],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Game Name', 'Enter game name'),
                const SizedBox(height: 12),
                _buildTextField(urlController, 'Game URL', 'https://example.com/game'),
                const SizedBox(height: 12),
                _buildTextField(descController, 'Description', 'Enter description', maxLines: 3),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Game Type',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'RENTED', child: Text('Rented/Third-Party')),
                    DropdownMenuItem(value: 'IN_HOUSE', child: Text('In-House')),
                    DropdownMenuItem(value: 'WEB_BASED', child: Text('Web-Based')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedReward,
                  decoration: InputDecoration(
                    labelText: 'Reward Type',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'COINS', child: Text('Coins')),
                    DropdownMenuItem(value: 'DIAMONDS', child: Text('Diamonds')),
                    DropdownMenuItem(value: 'BOTH', child: Text('Both')),
                  ],
                  onChanged: (value) => setState(() => selectedReward = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(minBetController, 'Min Bet', '10', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(maxBetController, 'Max Bet', '10000', keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(coinRatioController, 'Coin:Diamond Ratio', '100', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(diamondRatioController, 'Diamond:Coin Ratio', '0.01', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final gameData = {
                  'name': nameController.text,
                  'gameUrl': urlController.text,
                  'description': descController.text,
                  'gameType': selectedType,
                  'rewardType': selectedReward,
                  'minBetAmount': int.tryParse(minBetController.text) ?? 10,
                  'maxBetAmount': int.tryParse(maxBetController.text) ?? 10000,
                  'coinToDiamondRatio': int.tryParse(coinRatioController.text) ?? 100,
                  'diamondToCoinRatio': double.tryParse(diamondRatioController.text) ?? 0.01,
                };

                await controller.createGame(gameData);
                Get.back();
              },
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.orange)),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGameDialog(BuildContext context, WebViewGameModel game) {
    final nameController = TextEditingController(text: game.name);
    final urlController = TextEditingController(text: game.gameUrl);
    final descController = TextEditingController(text: game.description);
    final minBetController = TextEditingController(text: game.minBetAmount.toString());
    final maxBetController = TextEditingController(text: game.maxBetAmount.toString());
    final coinRatioController = TextEditingController(text: game.coinToDiamondRatio.toString());
    final diamondRatioController = TextEditingController(text: game.diamondToCoinRatio.toString());
    String selectedType = game.gameType;
    String selectedReward = game.rewardType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit: ${game.name}', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[850],
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, 'Game Name', 'Enter game name'),
                const SizedBox(height: 12),
                _buildTextField(urlController, 'Game URL', 'https://example.com/game'),
                const SizedBox(height: 12),
                _buildTextField(descController, 'Description', 'Enter description', maxLines: 3),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Game Type',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'RENTED', child: Text('Rented/Third-Party')),
                    DropdownMenuItem(value: 'IN_HOUSE', child: Text('In-House')),
                    DropdownMenuItem(value: 'WEB_BASED', child: Text('Web-Based')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedReward,
                  decoration: InputDecoration(
                    labelText: 'Reward Type',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[800],
                  ),
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'COINS', child: Text('Coins')),
                    DropdownMenuItem(value: 'DIAMONDS', child: Text('Diamonds')),
                    DropdownMenuItem(value: 'BOTH', child: Text('Both')),
                  ],
                  onChanged: (value) => setState(() => selectedReward = value!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(minBetController, 'Min Bet', '10', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(maxBetController, 'Max Bet', '10000', keyboardType: TextInputType.number),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(coinRatioController, 'Coin:Diamond Ratio', '100', keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(diamondRatioController, 'Diamond:Coin Ratio', '0.01', keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final updates = {
                  'name': nameController.text,
                  'gameUrl': urlController.text,
                  'description': descController.text,
                  'gameType': selectedType,
                  'rewardType': selectedReward,
                  'minBetAmount': int.tryParse(minBetController.text) ?? 10,
                  'maxBetAmount': int.tryParse(maxBetController.text) ?? 10000,
                  'coinToDiamondRatio': int.tryParse(coinRatioController.text) ?? 100,
                  'diamondToCoinRatio': double.tryParse(diamondRatioController.text) ?? 0.01,
                };

                await controller.updateGame(game.id, updates);
                Get.back();
              },
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.orange)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGame(BuildContext context, String gameId, String gameName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        content: Text(
          'Are you sure you want to delete "$gameName"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteGame(gameId);
              Get.back();
            },
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType ?? TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
        filled: true,
        fillColor: Colors.grey[800],
      ),
    );
  }
}