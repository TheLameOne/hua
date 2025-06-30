import 'package:flutter/material.dart';
import '../api/webrtc_service.dart';

enum CallState {
  idle,
  connecting,
  connected,
  disconnected,
  error,
}

class WebRTCProvider extends ChangeNotifier {
  final WebRTCService _webrtcService = WebRTCService.instance;

  CallState _callState = CallState.idle;

  String? _errorMessage;
  List<String> _participants = [];
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;

  // Getters
  CallState get callState => _callState;
  String? get errorMessage => _errorMessage;
  List<String> get participants => _participants;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;
  WebRTCService get webrtcService => _webrtcService;

  bool get isInCall =>
      _callState == CallState.connected || _callState == CallState.connecting;

  // Check if there's an active call that can be joined
  bool get hasActiveCallToJoin => _webrtcService.hasActiveCallToJoin;

  // Incoming call callback
  Function(String fromId, String callerName)? onIncomingCall;

  // Active call available callback
  Function()? onActiveCallAvailable;

  WebRTCProvider() {
    _initializeService();
  }

  void _initializeService() {
    _webrtcService.onParticipantsChanged = (participants) {
      _participants = participants;

      // Check if there's an active call available to join
      if (_webrtcService.hasActiveCallToJoin && onActiveCallAvailable != null) {
        onActiveCallAvailable!();
      }

      notifyListeners();
    };

    _webrtcService.onParticipantStreamChanged = (participantId, hasVideo) {
      // Stream changed for a participant
      notifyListeners();
    };

    _webrtcService.onError = (error) {
      _errorMessage = error;
      _callState = CallState.error;
      notifyListeners();
    };

    _webrtcService.onDisconnected = () {
      _callState = CallState.disconnected;

      _participants.clear();
      notifyListeners();
    };

    _webrtcService.onIncomingCall = (fromId, callerName) {
      // Forward the incoming call to the UI layer
      onIncomingCall?.call(fromId, callerName);
    };
  }

  Future<void> initialize() async {
    try {
      await _webrtcService.initialize();
    } catch (e) {
      _errorMessage = 'Failed to initialize WebRTC: $e';
      _callState = CallState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> startVideoCall({List<String>? peerIds}) async {
    await _startCall(videoEnabled: true, audioEnabled: true, peerIds: peerIds);
  }

  Future<void> startVoiceCall({List<String>? peerIds}) async {
    await _startCall(videoEnabled: false, audioEnabled: true, peerIds: peerIds);
  }

  Future<void> _startCall(
      {required bool videoEnabled,
      required bool audioEnabled,
      List<String>? peerIds}) async {
    try {
      _callState = CallState.connecting;

      _isVideoEnabled = videoEnabled;
      _isAudioEnabled = audioEnabled;
      _errorMessage = null;
      notifyListeners();

      await _webrtcService.startCall(
        videoEnabled: videoEnabled,
        audioEnabled: audioEnabled,
        peerIds: peerIds,
      );

      _callState = CallState.connected;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start call: $e';
      _callState = CallState.error;

      notifyListeners();
      rethrow;
    }
  }

  Future<void> joinCall(
      {bool videoEnabled = true, bool audioEnabled = true}) async {
    try {
      _callState = CallState.connecting;

      _isVideoEnabled = videoEnabled;
      _isAudioEnabled = audioEnabled;
      _errorMessage = null;
      notifyListeners();

      await _webrtcService.joinCall(
        videoEnabled: videoEnabled,
        audioEnabled: audioEnabled,
      );

      _callState = CallState.connected;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to join call: $e';
      _callState = CallState.error;

      notifyListeners();
      rethrow;
    }
  }

  // Add this method to the WebRTCProvider
  Future<void> joinExistingCall(
      {bool videoEnabled = true, bool audioEnabled = true}) async {
    try {
      print('🤝 Joining existing call');
      _callState = CallState.connecting;
      _isVideoEnabled = videoEnabled;
      _isAudioEnabled = audioEnabled;
      _errorMessage = null;
      notifyListeners();

      // Initialize the service first
      await _webrtcService.initialize();

      // Join the call (this will connect to WebSocket and handle existing peers)
      await _webrtcService.joinCall(
        videoEnabled: videoEnabled,
        audioEnabled: audioEnabled,
      );

      _callState = CallState.connected;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to join existing call: $e';
      _callState = CallState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkForActiveCall() async {
    try {
      await _webrtcService.checkForActiveCall();
    } catch (e) {
      _errorMessage = 'Failed to check for active call: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Add method to diagnose video transmission issues
  void diagnoseVideoTransmission() {
    _webrtcService.diagnoseVideoTransmission();
  }

  Future<void> toggleVideo() async {
    try {
      await _webrtcService.toggleVideo();
      _isVideoEnabled = _webrtcService.isVideoEnabled;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to toggle video: $e';
      notifyListeners();
    }
  }

  Future<void> toggleAudio() async {
    try {
      await _webrtcService.toggleAudio();
      _isAudioEnabled = _webrtcService.isAudioEnabled;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to toggle audio: $e';
      notifyListeners();
    }
  }

  Future<void> endCall() async {
    try {
      await _webrtcService.endCall();
      _callState = CallState.idle;

      _participants.clear();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to end call: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_callState == CallState.error) {
      _callState = CallState.idle;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _webrtcService.dispose();
    super.dispose();
  }
}
