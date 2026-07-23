import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get_storage/get_storage.dart';
import '../constants/env_config.dart';

class SocketService extends GetxService {
  late io.Socket _socket;
  final _box = GetStorage();
  final RxBool isConnected = false.obs;

  // Reactive observables for real-time admin data
  final RxMap<String, dynamic> liveStats = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> recentUserUpdates = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recentRoomUpdates = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> pendingWithdrawalRequest = Rxn<Map<String, dynamic>>();
  final RxInt withdrawalNotificationCount = 0.obs;

  SocketService() {
    _initSocket();
  }

  void updateToken(String newToken) {
    _socket.io.options?['auth'] = <String, dynamic>{'token': newToken};
    if (_socket.connected) {
      _socket.disconnect();
      _socket.connect();
    }
  }

  void refreshToken() {
    final token = _box.read('admin_token') ?? '';
    if (_socket.connected) {
      _socket.emit('auth:refresh', {'token': token});
    }
  }

  void _initSocket() {
    final token = _box.read('admin_token') ?? '';

    _socket = io.io(
      EnvConfig.socketUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'auth': <String, dynamic>{
          if (token.isNotEmpty) 'token': token,
        },
        'autoConnect': false,
        'reconnection': true,
        'reconnectionDelay': 5000,
        'reconnectionAttempts': 10,
      },
    );

    _socket.onConnect((_) {
      isConnected.value = true;
      final refreshedToken = _box.read('admin_token') ?? '';
      _socket.emit('auth', {'token': refreshedToken});
    });

    _socket.onDisconnect((_) {
      isConnected.value = false;
    });

    _socket.onConnectError((data) {
      isConnected.value = false;
    });

    _socket.on('reconnect', (_) {
      final token = _box.read('admin_token') ?? '';
      _socket.emit('auth', {'token': token});
    });

    _socket.on('admin:stats', (data) {
      if (data is Map) liveStats.value = Map<String, dynamic>.from(data);
    });

    _socket.on('admin:user_update', (data) {
      if (data is Map) {
        recentUserUpdates.insert(0, Map<String, dynamic>.from(data));
        if (recentUserUpdates.length > 50) recentUserUpdates.removeLast();
      }
    });

    _socket.on('admin:room_update', (data) {
      if (data is Map) {
        recentRoomUpdates.insert(0, Map<String, dynamic>.from(data));
        if (recentRoomUpdates.length > 50) recentRoomUpdates.removeLast();
      }
    });

    _socket.on('admin:withdrawal_request', (data) {
      if (data is Map) {
        pendingWithdrawalRequest.value = Map<String, dynamic>.from(data);
        withdrawalNotificationCount.value++;
      }
    });
  }

  void connect() {
    if (!_socket.connected) {
      _socket.connect();
    }
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void on(String event, dynamic Function(dynamic) handler) {
    _socket.on(event, handler);
  }

  void off(String event) {
    _socket.off(event);
  }

  void joinRoom(String roomName) {
    _socket.emit('join:admin_room', {'room': roomName});
  }

  void clearWithdrawalNotification() {
    withdrawalNotificationCount.value = 0;
    pendingWithdrawalRequest.value = null;
  }

  @override
  void onClose() {
    _socket.disconnect();
    _socket.clearListeners();
    super.onClose();
  }
}
