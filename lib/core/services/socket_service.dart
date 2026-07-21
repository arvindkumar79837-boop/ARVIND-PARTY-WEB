import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get_storage/get_storage.dart';
import '../constants/env_config.dart';

class SocketService extends GetxService {
  late io.Socket _socket;
  final _box = GetStorage();
  final RxBool isConnected = false.obs;

  SocketService() {
    _initSocket();
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
      debugPrint('Socket connected: ${_socket.id}');
    });

    _socket.onDisconnect((_) {
      isConnected.value = false;
      debugPrint('Socket disconnected');
    });

    _socket.onConnectError((data) {
      isConnected.value = false;
      debugPrint('Socket connection error: $data');
    });

    _socket.on('admin:stats', (data) {
      debugPrint('Live stats update: $data');
    });

    _socket.on('admin:user_update', (data) {
      debugPrint('User update: $data');
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

  @override
  void onClose() {
    _socket.disconnect();
    _socket.clearListeners();
    super.onClose();
  }
}
