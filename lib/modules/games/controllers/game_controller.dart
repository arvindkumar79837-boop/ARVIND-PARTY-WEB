import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../models/webview_game_model.dart';

class GameController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoadingGames = true.obs;
  var isLoadingLedger = true.obs;
  var isLoadingLeaderboard = true.obs;

  var games = <WebViewGameModel>[].obs;
  var ledgerEntries = <GameLedgerEntry>[].obs;
  var leaderboard = <GameLeaderboardEntry>[].obs;
  var ledgerSummary = Rxn<GameLedgerSummary>();

  var selectedGameType = Rxn<String>();
  var selectedPeriod = 'weekly'.obs;
  var errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    fetchAllGames();
    fetchLedger();
    fetchLeaderboard();
  }

  Future<void> fetchAllGames({String? gameType, bool? isActive}) async {
    try {
      isLoadingGames.value = true;
      errorMessage.value = null;

      final queryParams = <String, String>{};
      if (gameType != null) queryParams['gameType'] = gameType;
      if (isActive != null) queryParams['isActive'] = isActive.toString();

      final response = await _apiService.get('/games', queryParams: queryParams);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> gamesList = response['data'];
        games.assignAll(gamesList.map((game) => WebViewGameModel.fromJson(game)).toList());
      }
    } catch (e) {
      errorMessage.value = 'Failed to load games: $e';
    } finally {
      isLoadingGames.value = false;
    }
  }

  Future<void> createGame(Map<String, dynamic> gameData) async {
    try {
      isLoadingGames.value = true;
      errorMessage.value = null;

      await _apiService.post('/games', gameData);

      await fetchAllGames();
    } catch (e) {
      errorMessage.value = 'Failed to create game: $e';
    } finally {
      isLoadingGames.value = false;
    }
  }

  Future<void> updateGame(String gameId, Map<String, dynamic> updates) async {
    try {
      isLoadingGames.value = true;
      errorMessage.value = null;

      await _apiService.put('/games/$gameId', updates);

      await fetchAllGames();
    } catch (e) {
      errorMessage.value = 'Failed to update game: $e';
    } finally {
      isLoadingGames.value = false;
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      isLoadingGames.value = true;
      errorMessage.value = null;

      await _apiService.delete('/games/$gameId');

      await fetchAllGames();
    } catch (e) {
      errorMessage.value = 'Failed to delete game: $e';
    } finally {
      isLoadingGames.value = false;
    }
  }

  Future<void> fetchLedger({String? gameId, String? startDate, String? endDate}) async {
    try {
      isLoadingLedger.value = true;
      errorMessage.value = null;

      final queryParams = <String, String>{};
      if (gameId != null) queryParams['gameId'] = gameId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.get('/games/ledger', queryParams: queryParams);

      if (response['success'] == true) {
        if (response['data'] != null) {
          final List<dynamic> ledgerList = response['data'];
          ledgerEntries.assignAll(ledgerList.map((entry) => GameLedgerEntry.fromJson(entry)).toList());
        }
        if (response['summary'] != null) {
          ledgerSummary.value = GameLedgerSummary.fromJson(response);
        }
      }
    } catch (e) {
      errorMessage.value = 'Failed to load ledger: $e';
    } finally {
      isLoadingLedger.value = false;
    }
  }

  Future<void> fetchLeaderboard({String? gameId}) async {
    try {
      isLoadingLeaderboard.value = true;
      errorMessage.value = null;

      final queryParams = <String, String>{
        'period': selectedPeriod.value,
        'limit': '50',
      };
      if (gameId != null) queryParams['gameId'] = gameId;

      final response = await _apiService.get('/games/leaderboard', queryParams: queryParams);

      if (response['success'] == true && response['leaderboard'] != null) {
        final List<dynamic> leaderboardList = response['leaderboard'];
        leaderboard.assignAll(leaderboardList.map((entry) => GameLeaderboardEntry.fromJson(entry)).toList());
      }
    } catch (e) {
      errorMessage.value = 'Failed to load leaderboard: $e';
    } finally {
      isLoadingLeaderboard.value = false;
    }
  }

  void changeLeaderboardPeriod(String period) {
    selectedPeriod.value = period;
    fetchLeaderboard();
  }

  void filterByGameType(String? gameType) {
    selectedGameType.value = gameType;
    fetchAllGames(gameType: gameType);
  }

  void clearError() {
    errorMessage.value = null;
  }
}