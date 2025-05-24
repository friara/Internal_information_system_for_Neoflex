import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../data/message_notification_dto.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';

class WebSocketService {
  late StompClient _stompClient;
  final String baseUrl;
  final AuthRepositoryImpl _authRepository;
  final Function(MessageNotificationDTO) onMessageReceived;
  final Logger _logger = Logger();
  bool _isIntentionalDisconnect = false;
  String? _currentUserId;

  WebSocketService({
    required this.baseUrl,
    required AuthRepositoryImpl authRepository,
    required this.onMessageReceived,
  }) : _authRepository = authRepository;

  Future<void> connect() async {
    try {
      _isIntentionalDisconnect = false;
      final token = await _authRepository.getAccessToken();
      //_currentUserId = await _authRepository.getCurrentUser();

      _stompClient = StompClient(
        config: StompConfig(
          url: baseUrl,
          stompConnectHeaders: _buildStompHeaders(token),
          webSocketConnectHeaders: _buildWsHeaders(token),
          onConnect: _onConnect,
          onWebSocketError: _handleWebSocketError,
          onStompError: _handleStompError,
          reconnectDelay: const Duration(seconds: 5),
          connectionTimeout: const Duration(seconds: 10),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          beforeConnect: () async {
            _logger.i('Initiating WebSocket connection...');
            await Future.delayed(const Duration(milliseconds: 100));
          },
        ),
      );
      
      _stompClient.activate();
      _logger.i('WebSocket connection activated');
    } catch (e) {
      _logger.e('WebSocket connection failed: $e');
      _scheduleReconnect();
    }
  }

  Map<String, String> _buildStompHeaders(String? token) => {
    'heart-beat': '10000,10000',
    if (token != null) 'Authorization': 'Bearer $token'
  };

  Map<String, dynamic> _buildWsHeaders(String? token) => {
    if (token != null) 'Authorization': 'Bearer $token'
  };

  void _onConnect(StompFrame frame) {
    _logger.i('WebSocket connected successfully');
    
    _subscribeToMessages();
    _subscribeToErrors();
  }

void _subscribeToMessages() {
  _stompClient.subscribe(
    destination: '/user/queue/messages',
    headers: {},
    callback: (frame) {
      // Логирование сырых данных
      _logger.d('[WebSocket] Raw received frame:');
      _logger.d('Headers: ${frame.headers}');
      _logger.d('Body: ${frame.body}');
      
      try {
        _handleIncomingMessage(frame);
        _logger.i('[WebSocket] Message processed successfully');
      } catch (e, stackTrace) {
        _logger.e(
          '[WebSocket] Error processing message', 
          error: e, 
          stackTrace: stackTrace
        );
      }
    },
  );
}

  void _subscribeToErrors() {
    _stompClient.subscribe(
      destination: '/user/queue/errors',
      headers: {},
      callback: (frame) => _handleErrorNotification(frame),
    );
  }

void _handleIncomingMessage(StompFrame frame) {
  try {
    _logger.d('[WebSocket] Decoding message...');
    
    final rawBody = frame.body ?? '';
    final messageJson = jsonDecode(rawBody) as Map<String, dynamic>;
    
    _logger.d('[WebSocket] Decoded JSON: $messageJson');
    
    final message = MessageNotificationDTO.fromJson(messageJson);
    _logger.i('[WebSocket] Parsed message: ${message.toString()}');
    
    if (_shouldProcessMessage(message)) {
      _logger.d('[WebSocket] Dispatching message to handler');
      onMessageReceived(message);
    } else {
      _logger.w('[WebSocket] Message filtered out by processing rules');
    }
    
  } on FormatException catch (e) {
    _logger.e('[WebSocket] JSON Decode Error: ${e.message}');
    _logger.e('[WebSocket] Invalid JSON: ${frame.body}');
  } catch (e, stackTrace) {
    _logger.e(
      '[WebSocket] Message processing error',
      error: e,
      stackTrace: stackTrace
    );
  }
}

  bool _shouldProcessMessage(MessageNotificationDTO message) {
    // if (message.sender.id == _currentUserId) {
    //   _logger.d('Received own message, skipping');
    //   return false;
    // }
    return true;
  }

  void _handleErrorNotification(StompFrame frame) {
    try {
      final error = jsonDecode(frame.body!);
      _logger.e('Server error: ${error['message']}');
    } catch (e) {
      _logger.e('Error processing error notification: $e');
    }
  }

  void _handleWebSocketError(dynamic error) {
    if (!_isIntentionalDisconnect) {
      _logger.e('WebSocket connection error: $error');
      _scheduleReconnect();
    }
  }

  void _handleStompError(StompFrame errorFrame) {
    _logger.e('STOMP protocol error: ${errorFrame.body}');
  }

  void _scheduleReconnect() {
    if (!_isIntentionalDisconnect) {
      _logger.i('Scheduling reconnect in 5 seconds...');
      Future.delayed(const Duration(seconds: 5), () => connect());
    }
  }

  Future<void> disconnect() async {
    _isIntentionalDisconnect = true;
    _stompClient.deactivate();
    _logger.i('WebSocket intentionally disconnected');
  }

  Future<void> updateToken() async {
    _logger.i('Updating WebSocket credentials...');
    await disconnect();
    await connect();
  }

  bool get isConnected => _stompClient.connected;

}








// import 'package:stomp_dart_client/stomp_dart_client.dart';
// import '../data/MessageNotificationDTO.dart';
// import 'dart:convert';

// class WebSocketService {
//   late StompClient stompClient;
//   String _baseUrl;
//   String? _token;
//   final Function(MessageNotificationDTO) onMessageReceived;
//   final String? _currentUserId;

//   WebSocketService({
//     required String baseUrl,
//     required this.onMessageReceived,
//     String? token,
//     String? userId,
//   })  : _baseUrl = baseUrl,
//         _token = token,
//         _currentUserId = userId;

//   void connect() {
//     stompClient = StompClient(
//       config: StompConfig(
//         url: '$_baseUrl/ws-notifications',
//         webSocketConnectHeaders: _token != null ? {'Authorization': 'Bearer $_token'} : {},
//         onConnect: _onConnect,
//         onWebSocketError: (error) => _handleError(error),
//         reconnectDelay: const Duration(seconds: 5),
//         stompConnectHeaders: {'heart-beat': '10000,10000'},
//       ),
//     );
//     stompClient.activate();
//   }

//   void _onConnect(StompFrame frame) {
//     // Подписка на персональную очередь
//     stompClient.subscribe(
//       destination: '/user/queue/messages',
//       headers: {},
//       callback: (frame) {
//         final message = MessageNotificationDTO.fromJson(jsonDecode(frame.body!));
//         // if (message.sender.id != _currentUserId) {
//         //   onMessageReceived(message);
//         // }
//         onMessageReceived(message);
//       },
//     );
//   }

//   void _handleError(dynamic error) {
//     print('WebSocket error: $error');
//     disconnect();
//     Future.delayed(const Duration(seconds: 5), () => connect());
//   }

//   void disconnect() {
//     stompClient.deactivate();
//   }

//   void updateCredentials({String? newToken, String? userId}) {
//     _token = newToken;
//     _currentUserId = userId;
//     disconnect();
//     connect();
//   }
// }















// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';

// class WebSocketService {
//   late WebSocketChannel _channel;
//   final String _baseUrl;
//   String? _token;
  
//   WebSocketService({required String baseUrl, String? token})
//     : _baseUrl = baseUrl,
//       _token = token;

//   void connect() {
//     try {
//       _channel = IOWebSocketChannel.connect(
//         Uri.parse('$_baseUrl/ws-notifications'),
//         headers: _token != null ? {'Authorization': 'Bearer $_token'} : null,
//       );
//     } catch (e) {
//       print('WebSocket connection error: $e');
//       _scheduleReconnect();
//     }
//   }

//   void _scheduleReconnect() {
//     Future.delayed(const Duration(seconds: 5), () => connect());
//   }

//   Stream get stream => _channel.stream;

//   void sendMessage(String message) {
//     if (_channel.closeCode == null) {
//       _channel.sink.add(message);
//     }
//   }

//   void updateToken(String newToken) {
//     _token = newToken;
//     disconnect();
//     connect();
//   }

//   void disconnect() {
//     _channel.sink.close();
//   }
// }