import 'dart:async';
import 'package:grpc/grpc.dart';
import 'package:hua/proto/generated/bidirectional.pbgrpc.dart' as proto;

import '../../services/secure_storage_service.dart';

class ChatService {
  late ClientChannel _channel;
  late proto.BidirectionalClient _stub;
  StreamController<proto.Request>? _requestController;
  Stream<proto.Response>? _responseStream;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Keep alive timer
  Timer? _keepAliveTimer;

  // Track connection state
  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;
  bool get isConnected =>
      _requestController != null && !_requestController!.isClosed;

  Future<void> connect() async {
    if (_isConnecting) return;

    _isConnecting = true;
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      } // Create channel with proper options using secure domain
      _channel = ClientChannel(
        'grpc.geonotes.in', // Updated to use domain instead of IP
        port: 443, // Updated to use HTTPS/TLS port
        options: const ChannelOptions(
          credentials:
              ChannelCredentials.secure(), // Updated to use secure credentials
          idleTimeout: Duration(minutes: 5), // Increased from 1 minute
          connectionTimeout: Duration(seconds: 15), // Increased from 10 seconds
          // keepAlive: ClientKeepAliveOptions(
          //   timeout: Duration(seconds: 30), // Increased from 10 seconds
          //   permitWithoutCalls: true,
          // ),
        ),
      );

      final callOptions = CallOptions(
        timeout: Duration(minutes: 30),
        metadata: {
          'authorization': 'Bearer $token',
        },
      );

      print(
          'Connecting to ${_channel.host}:${_channel.port} with TLS and keepalive');
      _stub = proto.BidirectionalClient(
        _channel,
        options: callOptions,
      );

      print('Created stub: $_stub');

      // Create a request controller
      _requestController = StreamController<proto.Request>();

      // Get the response stream by passing the request controller's stream
      _responseStream = _stub.chatty(
        _requestController!.stream,
        options: callOptions,
      );
      print('Secure stream created with keepalive');

      // Start application-level ping to ensure connection stays alive
      // _startKeepAlivePing();
    } catch (e) {
      print('Error connecting to gRPC server: $e');
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  // Send periodic empty messages to keep connection alive
  void _startKeepAlivePing() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (isConnected) {
        try {
          // Send an application-level ping with an empty message
          // Use a space character instead of empty string to avoid issues
          final pingRequest = proto.Request()..clientMessage = " ";

          _requestController!.add(pingRequest);
          print('Keepalive ping sent');
        } catch (e) {
          print('Error sending keepalive ping: $e');
          // If ping fails, cancel the timer to prevent further attempts
          timer.cancel();
        }
      } else {
        print('Connection lost, stopping keepalive');
        timer.cancel();
      }
    });
    print('Keepalive timer started (1 minute intervals)');
  }

  Stream<proto.Response>? get responseStream => _responseStream;

  void sendUsername(String username) {
    if (_requestController == null || _requestController!.isClosed) {
      throw Exception('Not connected to server');
    }

    final usernameRequest = proto.Request()..userName = username;
    _requestController!.add(usernameRequest);
    print('Username sent: $username');
  }

  void sendMessage(String message) {
    if (_requestController == null || _requestController!.isClosed) {
      throw Exception('Not connected to server');
    }

    final messageRequest = proto.Request()..clientMessage = message;
    _requestController!.add(messageRequest);
    print('Message sent: $message');
  }

  Future<void> disconnect() async {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;

    if (_requestController != null && !_requestController!.isClosed) {
      await _requestController!.close();
    }

    try {
      await _channel.shutdown();
      print('Disconnected from server');
    } catch (e) {
      print('Error during disconnect: $e');
    }
  }

  // Additional method to reconnect when connection is lost
  Future<bool> reconnect() async {
    try {
      await disconnect();
      await connect();
      return true;
    } catch (e) {
      print('Reconnection failed: $e');
      return false;
    }
  }
}
