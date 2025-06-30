import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../services/secure_storage_service.dart';
import '../../services/fcm_service.dart';
import '../../users_profile/api/user_profile_service.dart';

class WebRTCService {
  static const String wsUrl = 'wss://api.geonotes.in/ws'; // WebSocket endpoint

  // Singleton pattern to prevent multiple instances
  static WebRTCService? _instance;
  static WebRTCService get instance {
    _instance ??= WebRTCService._internal();
    return _instance!;
  }

  WebRTCService._internal();

  // Factory constructor for backward compatibility
  factory WebRTCService() => instance;

  // WebSocket connection
  WebSocketChannel? _wsChannel;
  bool _isConnected = false;

  // Add a flag to prevent multiple simultaneous calls
  bool _isCallInProgress = false;

  // Secure storage for token
  final SecureStorageService _secureStorage = SecureStorageService();

  // Multiple peer connections for multiple participants
  Map<String, RTCPeerConnection> _peerConnections = {};
  Map<String, MediaStream> _remoteStreams = {};
  Map<String, RTCVideoRenderer> _remoteRenderers = {};

  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  String? _userId;
  List<String> _participants = [];
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isCheckingForActiveCall = false;

  // Store SDP descriptions for debugging
  Map<String, String> _localOffers = {};
  Map<String, String> _localAnswers = {};
  Map<String, String> _remoteOffers = {};
  Map<String, String> _remoteAnswers = {};

  // Store ICE candidates for debugging
  Map<String, List<RTCIceCandidate>> _localIceCandidates = {};
  Map<String, List<RTCIceCandidate>> _remoteIceCandidates = {};

  // Queue for ICE candidates that arrive before remote description is set
  Map<String, List<RTCIceCandidate>> _queuedIceCandidates = {};

  // Track connections being created to prevent race conditions
  Map<String, bool> _creatingConnections = {};

  // Callbacks
  Function(String participantId, bool hasVideo)? onParticipantStreamChanged;
  Function(List<String> participants)? onParticipantsChanged;
  Function(String error)? onError;
  Function()? onDisconnected;
  Function(String fromId, String callerName)? onIncomingCall;

  // Getters
  RTCVideoRenderer get localRenderer => _localRenderer;
  List<String> get participants => _participants;
  Map<String, RTCVideoRenderer> get remoteRenderers => _remoteRenderers;
  Map<String, MediaStream> get remoteStreams => _remoteStreams;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;

  String? get userId => _userId;
  bool get isConnected => _isConnected;

  // Check if there's an active call that can be joined (has existing participants)
  bool get hasActiveCallToJoin =>
      _participants.isNotEmpty &&
      (_localStream == null || _isCheckingForActiveCall);

  // Add getter for camera switching capability
  bool get canSwitchCamera =>
      _localStream != null && _localStream!.getVideoTracks().isNotEmpty;

  // Debug getters for SDP viewer
  Map<String, String> get localOffers => _localOffers;
  Map<String, String> get localAnswers => _localAnswers;
  Map<String, String> get remoteOffers => _remoteOffers;
  Map<String, String> get remoteAnswers => _remoteAnswers;
  Map<String, List<RTCIceCandidate>> get localIceCandidates =>
      _localIceCandidates;
  Map<String, List<RTCIceCandidate>> get remoteIceCandidates =>
      _remoteIceCandidates;

  // Convenience getters for single participant debugging (backward compatibility)
  String? get localOfferSdp =>
      _localOffers.values.isNotEmpty ? _localOffers.values.first : null;
  String? get localAnswerSdp =>
      _localAnswers.values.isNotEmpty ? _localAnswers.values.first : null;
  String? get remoteOfferSdp =>
      _remoteOffers.values.isNotEmpty ? _remoteOffers.values.first : null;
  String? get remoteAnswerSdp =>
      _remoteAnswers.values.isNotEmpty ? _remoteAnswers.values.first : null;

  Future<void> initialize() async {
    try {
      await _localRenderer.initialize();

      // Try to get user ID from username
      final username = await _secureStorage.getUsername();
      if (username != null) {
        try {
          // Get user profile to extract user ID
          final userProfileService = UserProfileService();
          final userProfile = await userProfileService.getUserProfile(username);
          if (userProfile != null) {
            _userId = userProfile.id;
            log('WebRTC initialized for user ID: $_userId (username: $username)');
          } else {
            // Fallback to username if profile not found
            _userId = username;
            log('WebRTC initialized with username fallback: $_userId');
          }
        } catch (e) {
          log('Error getting user profile, using username: $e');
          _userId = username;
        }
      } else {
        // Ultimate fallback to timestamp
        _userId = DateTime.now().millisecondsSinceEpoch.toString();
        log('WebRTC initialized with timestamp fallback: $_userId');
      }

      log('WebRTC initialized for user: $_userId');
    } catch (e) {
      log('WebRTC initialization error: $e');
      onError?.call('Failed to initialize WebRTC: $e');
      rethrow;
    }
  }

  Future<void> _connectWebSocket() async {
    if (_isConnected) return;

    try {
      // Get authentication token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      // Create WebSocket connection with Authorization header
      final socket = await WebSocket.connect(
        wsUrl,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      _wsChannel = IOWebSocketChannel(socket);
      _isConnected = true;

      // Listen to WebSocket messages
      _wsChannel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          log('WebSocket error: $error');
          _isConnected = false;
          onError?.call('WebSocket connection error: $error');
        },
        onDone: () {
          log('WebSocket connection closed');
          _isConnected = false;
          _handleDisconnection();
        },
      );

      log('WebSocket connected successfully with authentication');
    } catch (e) {
      log('Failed to connect WebSocket: $e');
      _isConnected = false;
      onError?.call('Failed to connect to signaling server: $e');
      rethrow;
    }
  }

  void _handleWebSocketMessage(dynamic message) async {
    try {
      final data = jsonDecode(message);
      // Force print to ensure we see this log
      print(
          '🔥 WEBRTC MESSAGE: ${data['type']} from ${data['from'] ?? 'server'}');
      log('📨 Received WebSocket message: ${data['type']} from ${data['from'] ?? 'server'}');

      switch (data['type']) {
        case 'existing-peers':
          print('👥 Existing peers: ${data['peer_ids']}');
          await _handleExistingPeers(data['peer_ids']);
          break;
        case 'new-peer':
          print('👤 New peer: ${data['peer_id']}');
          await _handleNewPeer(data['peer_id']);
          break;
        case 'peer-left':
          print('👋 Peer left: ${data['peer_id']}');
          _handlePeerLeft(data['peer_id']);
          break;
        case 'incoming-call':
          print('📞 Incoming call from: ${data['caller_name']}');
          _handleIncomingCall(data['from'], data['caller_name']);
          break;
        case 'offer':
          print('🤝 Received OFFER from: ${data['from']}');
          await _handleOffer(data['from'], data['sdp']);
          break;
        case 'answer':
          print('✅ Received ANSWER from: ${data['from']}');
          await _handleAnswer(data['from'], data['sdp']);
          break;
        case 'candidate':
          print('🧊 Received ICE candidate from: ${data['from']}');
          await _handleIceCandidate(
            data['from'],
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
          // Log ICE candidate stats for debugging
          logIceCandidateStats();
          break;
        default:
          print('❓ Unknown message: ${data['type']}');
          log('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('❌ WebSocket message error: $e');
      log('Error handling WebSocket message: $e');
    }
  }

  Future<void> startCall({
    bool videoEnabled = true,
    bool audioEnabled = true,
    List<String>? peerIds,
  }) async {
    if (_isCallInProgress) {
      log('⚠️ Call already in progress, ignoring duplicate startCall');
      return;
    }

    try {
      _isCallInProgress = true;
      print(
          '🚀 START CALL - video: $videoEnabled, audio: $audioEnabled, peers: $peerIds');
      _isCheckingForActiveCall = false;
      _isVideoEnabled = videoEnabled;
      _isAudioEnabled = audioEnabled;

      print('🌐 Connecting WebSocket...');
      await _connectWebSocket();

      print('📹 Getting user media...');
      await _getUserMedia();

      // Get FCM token and join the signaling server
      final fcmService = FCMService();
      final fcmToken = await fcmService.getFCMToken();
      print('🔔 FCM token length: ${fcmToken?.length ?? 0}');

      print('🤝 Sending JOIN message');
      _sendMessage({
        'type': 'join',
        'fcm_token': fcmToken ?? '',
      });

      // If specific peer IDs provided, start call with them
      if (peerIds != null && peerIds.isNotEmpty) {
        print('📞 Sending START_CALL message with peers: $peerIds');
        log('Starting call with peer IDs: $peerIds');
        _sendMessage({
          'type': 'start_call',
          'peer_ids': peerIds,
        });
      } else {
        print('📞 No peer IDs provided - general join');
        log('No peer IDs provided, joining general call');
      }
    } catch (e) {
      _isCallInProgress = false; // Reset on error
      print('❌ START CALL ERROR: $e');
      log('Error starting call: $e');
      onError?.call('Failed to start call: $e');
      rethrow;
    }
  }

  Future<void> joinCall({
    bool videoEnabled = true,
    bool audioEnabled = true,
  }) async {
    if (_isCallInProgress) {
      log('⚠️ Call already in progress, ignoring duplicate joinCall');
      return;
    }

    try {
      _isCallInProgress = true;
      print('🚀 JOIN CALL - video: $videoEnabled, audio: $audioEnabled');
      _isCheckingForActiveCall = false;
      _isVideoEnabled = videoEnabled;
      _isAudioEnabled = audioEnabled;

      print('🌐 Connecting WebSocket...');
      await _connectWebSocket();

      print('📹 Getting user media...');
      await _getUserMedia();

      // Get FCM token and join the signaling server
      final fcmService = FCMService();
      final fcmToken = await fcmService.getFCMToken();
      print('🔔 FCM token length: ${fcmToken?.length ?? 0}');

      print('🤝 Sending JOIN message');
      _sendMessage({
        'type': 'join',
        'fcm_token': fcmToken ?? '',
      });
    } catch (e) {
      _isCallInProgress = false; // Reset on error
      print('❌ JOIN CALL ERROR: $e');
      log('Error joining call: $e');
      onError?.call('Failed to join call: $e');
      rethrow;
    }
  }

  Future<void> checkForActiveCall() async {
    try {
      _isCheckingForActiveCall = true;
      await _connectWebSocket();

      // Get FCM token and join the signaling server to check for existing peers
      final fcmService = FCMService();
      final fcmToken = await fcmService.getFCMToken();

      _sendMessage({
        'type': 'join',
        'fcm_token': fcmToken ?? '',
      });

      log('Checking for active call...');
    } catch (e) {
      log('Error checking for active call: $e');
      onError?.call('Failed to check for active call: $e');
      rethrow;
    }
  }

  Future<void> _getUserMedia() async {
    try {
      // Release any existing stream first to prevent camera conflicts
      if (_localStream != null) {
        await _localStream!.dispose();
        _localStream = null;
        // Small delay to ensure camera is released
        await Future.delayed(const Duration(milliseconds: 500));
      }

      Map<String, dynamic> constraints = {
        'audio': _isAudioEnabled
            ? {
                'echoCancellation': true,
                'noiseSuppression': true,
                'autoGainControl': true,
              }
            : false,
        'video': _isVideoEnabled
            ? {
                'width': {'min': 640, 'ideal': 1280, 'max': 1280},
                'height': {'min': 480, 'ideal': 720, 'max': 720},
                'frameRate': {'min': 15, 'ideal': 30, 'max': 30},
                'facingMode': 'user',
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;

      log('Local stream obtained - video: ${_localStream!.getVideoTracks().length}, audio: ${_localStream!.getAudioTracks().length}');

      // Verify video tracks are enabled and working
      for (var track in _localStream!.getVideoTracks()) {
        log('Video track: enabled=${track.enabled}, kind=${track.kind}, label=${track.label}');
      }
      for (var track in _localStream!.getAudioTracks()) {
        log('Audio track: enabled=${track.enabled}, kind=${track.kind}, label=${track.label}');
      }
    } catch (e) {
      log('Error getting user media: $e');
      // Fallback to simpler constraints
      try {
        // Wait a bit before retry
        await Future.delayed(const Duration(milliseconds: 1000));

        _localStream = await navigator.mediaDevices.getUserMedia({
          'video': _isVideoEnabled
              ? {
                  'width': {'ideal': 480}, // Lower resolution for stability
                  'height': {'ideal': 360},
                  'frameRate': {'ideal': 15},
                }
              : false,
          'audio': _isAudioEnabled,
        });
        _localRenderer.srcObject = _localStream;
        log('Fallback media stream obtained');
      } catch (fallbackError) {
        log('Fallback getUserMedia failed: $fallbackError');
        onError?.call('Failed to access camera/microphone: $fallbackError');
        rethrow;
      }
    }
  }

  Future<void> _handleNewPeer(String peerId) async {
    log('New peer joined: $peerId');
    print('👤 New peer joined: $peerId - existing participant sends offer');

    if (!_participants.contains(peerId)) {
      _participants.add(peerId);
      onParticipantsChanged?.call(_participants);
    }

    // CRITICAL FIX: Existing participants should also send offers to new peers
    // This creates a dual-path approach ensuring connections are established
    // Both the new joiner (in _handleExistingPeers) and existing peers send offers
    if (!_peerConnections.containsKey(peerId)) {
      print('🚀 EXISTING PEER SENDS OFFER to new peer: $peerId');
      await _createConnectionToParticipant(
          peerId, false); // Existing peer sends offer
    } else {
      print('✅ Peer connection already exists for: $peerId');
    }

    // Log detailed peer connection states for debugging
    logPeerConnectionStates();
  }

  void _handlePeerLeft(String peerId) {
    log('Peer left: $peerId');

    _participants.remove(peerId);
    _peerConnections[peerId]?.close();
    _peerConnections.remove(peerId);
    _remoteStreams[peerId]?.dispose();
    _remoteStreams.remove(peerId);
    _remoteRenderers[peerId]?.dispose();
    _remoteRenderers.remove(peerId);

    // Clean up ICE candidate data
    _localIceCandidates.remove(peerId);
    _remoteIceCandidates.remove(peerId);
    _queuedIceCandidates.remove(peerId);
    _creatingConnections.remove(peerId); // Clean up race condition tracker

    onParticipantsChanged?.call(_participants);
  }

  void _handleIncomingCall(String fromId, String callerName) {
    log('Incoming call from: $callerName ($fromId)');
    onIncomingCall?.call(fromId, callerName);
  }

  Future<RTCPeerConnection> _createPeerConnectionForParticipant(
      String participantId) async {
    log('Creating peer connection for participant: $participantId');

    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun1.l.google.com:19302'},
        {'urls': 'stun:stun2.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };

    final peerConnection = await createPeerConnection(configuration);

    _localIceCandidates[participantId] = [];
    _remoteIceCandidates[participantId] = [];
    _queuedIceCandidates[participantId] =
        []; // Initialize queue for this participant

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      log('ICE Candidate for $participantId');
      _localIceCandidates[participantId]?.add(candidate);

      _sendMessage({
        'type': 'candidate',
        'to': participantId,
        'from': _userId,
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    peerConnection.onTrack = (RTCTrackEvent event) {
      print('🎯 TRACK EVENT for $participantId:');
      print('  - Track kind: ${event.track.kind}');
      print('  - Track ID: ${event.track.id}');
      print('  - Track enabled: ${event.track.enabled}');
      print('  - Track muted: ${event.track.muted}');
      print('  - Streams count: ${event.streams.length}');

      for (int i = 0; i < event.streams.length; i++) {
        final stream = event.streams[i];
        print('  - Stream $i ID: ${stream.id}');
        print('  - Stream $i video tracks: ${stream.getVideoTracks().length}');
        print('  - Stream $i audio tracks: ${stream.getAudioTracks().length}');
      }

      log('Remote track added for $participantId - kind: ${event.track.kind}, streams: ${event.streams.length}');
      log('Track enabled: ${event.track.enabled}, muted: ${event.track.muted}');

      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        _remoteStreams[participantId] = stream;

        print('🎉 REMOTE STREAM STORED for $participantId');
        print('  - Stream ID: ${stream.id}');
        print('  - Video tracks: ${stream.getVideoTracks().length}');
        print('  - Audio tracks: ${stream.getAudioTracks().length}');

        log('Remote stream for $participantId - video tracks: ${stream.getVideoTracks().length}, audio tracks: ${stream.getAudioTracks().length}');

        if (_remoteRenderers[participantId] != null) {
          print('🖥️  SETTING RENDERER for $participantId');
          _remoteRenderers[participantId]!.srcObject = stream;

          // Check if this is a video track
          final hasVideo = stream.getVideoTracks().isNotEmpty;
          print(
              '📹 Calling onParticipantStreamChanged for $participantId with video: $hasVideo');
          log('Setting renderer for $participantId with video: $hasVideo');

          onParticipantStreamChanged?.call(participantId, hasVideo);
        } else {
          print('❌ NO RENDERER for $participantId - cannot display stream!');
          log('Warning: No renderer available for $participantId');
        }
      } else {
        print('❌ TRACK EVENT has NO STREAMS for $participantId');
        log('Warning: Track event for $participantId has no streams');
      }
    };

    peerConnection.onConnectionState = (RTCPeerConnectionState state) {
      log('Connection state for $participantId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _handlePeerLeft(participantId);
      }
    };

    peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      log('ICE connection state for $participantId: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        log('ICE connection established for $participantId - video should start flowing');

        // Log connection states after ICE establishment
        Future.delayed(const Duration(milliseconds: 500), () {
          logPeerConnectionStates();
        });

        // Check outgoing tracks after connection is established
        Future.delayed(const Duration(milliseconds: 1000), () {
          checkOutgoingTracks();
        });

        // Debug track events after connection is established
        Future.delayed(const Duration(milliseconds: 1500), () {
          debugTrackEvents();
        });

        // Run diagnosis after connection is established
        Future.delayed(const Duration(seconds: 2), () {
          runVideoTransmissionDiagnostics(participantId);
        });
      } else if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
          state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
        log('ICE connection failed/disconnected for $participantId');
      }
    };

    peerConnection.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE gathering state for $participantId: $state');
    };

    // Add local tracks
    if (_localStream != null) {
      print('🚀 ADDING LOCAL TRACKS to peer connection for $participantId:');

      for (var track in _localStream!.getTracks()) {
        print(
            '  - Adding ${track.kind} track: ${track.id} (enabled: ${track.enabled})');
        await peerConnection.addTrack(track, _localStream!);
        log('Added ${track.kind} track for $participantId - enabled: ${track.enabled}');

        // Ensure video track is enabled and ready
        if (track.kind == 'video') {
          print(
              '  - Video track details: enabled=${track.enabled}, muted=${track.muted}');
          log('Video track details for $participantId: enabled=${track.enabled}');
        }
      }

      print('✅ ALL LOCAL TRACKS ADDED for $participantId');

      // Verify tracks were added by checking senders
      final senders = await peerConnection.getSenders();
      print('📤 SENDERS for $participantId: ${senders.length}');
      for (var sender in senders) {
        if (sender.track != null) {
          print(
              '  - Sender: ${sender.track!.kind} track ${sender.track!.id} (enabled: ${sender.track!.enabled})');
        } else {
          print('  - Sender with no track');
        }
      }

      // Note: Transceiver direction handling removed due to API compatibility issues
      // The WebRTC implementation should default to proper sendrecv behavior
    } else {
      print(
          '❌ NO LOCAL STREAM when creating peer connection for $participantId');
      log('Warning: No local stream available when creating peer connection for $participantId');
    }

    return peerConnection;
  }

  Future<void> _createConnectionToParticipant(
      String participantId, bool isOfferer) async {
    print('🔗 Creating connection to: $participantId (offerer: $isOfferer)');
    log('Creating connection to participant: $participantId (offerer: $isOfferer)');

    // Check if connection already exists or is being created to prevent duplicates
    if (_peerConnections.containsKey(participantId)) {
      print('✅ Peer connection already exists for: $participantId');
      return;
    }

    if (_creatingConnections.containsKey(participantId)) {
      print('⏳ Connection already being created for: $participantId');
      return;
    }

    // Mark as being created to prevent race conditions
    _creatingConnections[participantId] = true;

    try {
      await _createRendererForParticipant(participantId);

      final peerConnection =
          await _createPeerConnectionForParticipant(participantId);
      _peerConnections[participantId] = peerConnection;

      print('✅ Peer connection created for: $participantId');

      if (isOfferer) {
        print('📝 Creating and sending offer to: $participantId');
        await _createAndSendOffer(participantId, peerConnection);
      } else {
        print('⏳ Waiting for offer from: $participantId');
      }
    } finally {
      // Always clean up the creation flag
      _creatingConnections.remove(participantId);
    }
  }

  Future<RTCVideoRenderer> _createRendererForParticipant(
      String participantId) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    _remoteRenderers[participantId] = renderer;
    return renderer;
  }

  Future<void> _createAndSendOffer(
      String participantId, RTCPeerConnection peerConnection) async {
    try {
      // Create offer with explicit audio/video constraints
      final offerOptions = {
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': true,
        'voiceActivityDetection': false,
        'iceRestart': false,
      };

      log('Creating offer for $participantId with options: $offerOptions');
      RTCSessionDescription offer =
          await peerConnection.createOffer(offerOptions);

      log('Setting local description for $participantId');
      await peerConnection.setLocalDescription(offer);

      // Wait a moment for the local description to be fully processed
      await Future.delayed(const Duration(milliseconds: 100));

      _localOffers[participantId] = offer.sdp!;

      log('Created offer for $participantId');
      log('Offer SDP contains video: ${offer.sdp!.contains('m=video')}');
      log('Offer SDP contains audio: ${offer.sdp!.contains('m=audio')}');

      // Debug: Log the IDs being used
      print('🔍 Offer message - to: $participantId, from: $_userId');

      _sendMessage({
        'type': 'offer',
        'to': participantId,
        'from': _userId,
        'sdp': offer.sdp,
      });

      log('Offer sent successfully for participant: $participantId');
    } catch (e) {
      log('Error creating offer for $participantId: $e');
      onError?.call('Failed to create offer: $e');
    }
  }

  Future<void> _handleOffer(String fromId, String sdp) async {
    try {
      log('Handling offer from: $fromId');
      print('🤝 Handling offer from: $fromId');

      if (!_participants.contains(fromId)) {
        _participants.add(fromId);
        onParticipantsChanged?.call(_participants);
      }

      // If we don't have a peer connection yet, create one
      if (!_peerConnections.containsKey(fromId)) {
        print('🔗 Creating peer connection for incoming offer from: $fromId');
        await _createConnectionToParticipant(fromId, false);
      }

      final peerConnection = _peerConnections[fromId];
      if (peerConnection == null) {
        log('❌ Failed to create peer connection for: $fromId');
        return;
      }

      // Check if we're in a state to handle the offer
      if (peerConnection.signalingState ==
              RTCSignalingState.RTCSignalingStateStable ||
          peerConnection.signalingState ==
              RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        // If we have a local offer pending, we need to decide who should back down
        // Use a simple comparison: lower user ID becomes the answerer
        if (peerConnection.signalingState ==
            RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          if (_userId != null && fromId.compareTo(_userId!) < 0) {
            print(
                '🔄 Collision detected - backing down and accepting offer from: $fromId');
            // Reset to stable state and accept their offer
            await peerConnection
                .setLocalDescription(RTCSessionDescription('', 'rollback'));
          } else {
            print(
                '🔄 Collision detected - ignoring offer from: $fromId (we have priority)');
            return;
          }
        }

        log('Setting remote description (offer) for $fromId');
        await peerConnection.setRemoteDescription(
          RTCSessionDescription(sdp, 'offer'),
        );

        // Wait a moment for the remote description to be fully processed
        await Future.delayed(const Duration(milliseconds: 100));

        // Process any queued ICE candidates now that remote description is set
        await _processQueuedIceCandidates(fromId);

        _remoteOffers[fromId] = sdp;

        // CRITICAL FIX: Ensure local tracks are added before creating answer
        // This prevents the answer SDP from being 'recvonly' instead of 'sendrecv'
        if (_localStream != null) {
          log('Ensuring local tracks are added to peer connection for $fromId before creating answer');

          // Get current senders to check what's already added
          final currentSenders = await peerConnection.getSenders();
          final currentTrackIds = currentSenders
              .where((sender) => sender.track != null)
              .map((sender) => sender.track!.id)
              .toSet();

          // Add any missing local tracks
          for (var track in _localStream!.getTracks()) {
            if (!currentTrackIds.contains(track.id)) {
              await peerConnection.addTrack(track, _localStream!);
              log('Added missing ${track.kind} track ${track.id} to peer connection for $fromId');
            } else {
              log('${track.kind} track ${track.id} already added to peer connection for $fromId');
            }
          }

          // Small delay to ensure tracks are fully registered
          await Future.delayed(const Duration(milliseconds: 50));
        } else {
          log('WARNING: No local stream available when handling offer from $fromId - answer may be recvonly');
        }

        final answerOptions = {
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': true,
          'voiceActivityDetection': false,
        };

        log('Creating answer for $fromId with options: $answerOptions');
        RTCSessionDescription answer =
            await peerConnection.createAnswer(answerOptions);

        log('Setting local description (answer) for $fromId');
        await peerConnection.setLocalDescription(answer);

        // Wait a moment for the local description to be fully processed
        await Future.delayed(const Duration(milliseconds: 100));

        _localAnswers[fromId] = answer.sdp!;

        log('Created answer for $fromId');
        log('Answer SDP contains video: ${answer.sdp!.contains('m=video')}');
        log('Answer SDP contains audio: ${answer.sdp!.contains('m=audio')}');

        // Check if answer is sendrecv (should be after our fix)
        if (answer.sdp!.contains('sendrecv')) {
          log('✅ Answer SDP is sendrecv - bidirectional video should work');
        } else if (answer.sdp!.contains('recvonly')) {
          log('❌ Answer SDP is recvonly - this indicates local tracks were not properly added');
        } else {
          log('⚠️ Answer SDP direction unclear - checking further');
        }

        // Debug: Log the IDs being used
        print('🔍 Answer message - to: $fromId, from: $_userId');

        _sendMessage({
          'type': 'answer',
          'to': fromId,
          'from': _userId,
          'sdp': answer.sdp,
        });

        log('Answer sent successfully to: $fromId');
      } else {
        log('⚠️ Cannot handle offer in current signaling state: ${peerConnection.signalingState}');
      }
    } catch (e) {
      log('Error handling offer from $fromId: $e');
      onError?.call('Failed to handle offer: $e');
    }
  }

  Future<void> _handleAnswer(String fromId, String sdp) async {
    try {
      log('Handling answer from: $fromId');

      log('Setting remote description (answer) for $fromId');
      final peerConnection = _peerConnections[fromId];
      if (peerConnection != null) {
        await peerConnection.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer'),
        );

        // Wait a moment for the remote description to be fully processed
        await Future.delayed(const Duration(milliseconds: 100));

        // Process any queued ICE candidates now that remote description is set
        await _processQueuedIceCandidates(fromId);

        _remoteAnswers[fromId] = sdp;
        log('Answer processed successfully from: $fromId');
      }
    } catch (e) {
      log('Error handling answer from $fromId: $e');
      onError?.call('Failed to handle answer from $fromId: $e');
    }
  }

  Future<void> _handleIceCandidate(
    String fromId,
    String candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  ) async {
    try {
      print('🧊 Received ICE candidate from: $fromId');
      print('🧊 ICE candidate details:');
      print('   From: $fromId');
      print('   Candidate: $candidate');
      print('   SDP Mid: $sdpMid');
      print('   SDP MLine Index: $sdpMLineIndex');

      final peerConnection = _peerConnections[fromId];
      if (peerConnection == null) {
        print('⚠️ No peer connection found for: $fromId - queueing candidate');

        // Queue the candidate for later processing
        _queuedIceCandidates[fromId] ??= [];
        _queuedIceCandidates[fromId]!
            .add(RTCIceCandidate(candidate, sdpMid, sdpMLineIndex));

        print(
            '📦 Queued ICE candidate for: $fromId (total queued: ${_queuedIceCandidates[fromId]!.length})');

        // If we have existing peers but no peer connection, create one (with race condition protection)
        if (_participants.contains(fromId) &&
            !_creatingConnections.containsKey(fromId)) {
          print('🔗 Creating delayed peer connection for: $fromId');
          _creatingConnections[fromId] = true;
          try {
            await _createConnectionToParticipant(fromId,
                false); // We are not the offerer since they're sending candidates
          } finally {
            _creatingConnections.remove(fromId);
          }
        }

        logIceCandidateStats();
        return;
      }

      // Rest of the existing ICE candidate handling logic...
      final iceCandidate = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);

      if (peerConnection.signalingState ==
              RTCSignalingState.RTCSignalingStateHaveRemoteOffer ||
          peerConnection.signalingState ==
              RTCSignalingState.RTCSignalingStateStable) {
        await peerConnection.addCandidate(iceCandidate);
        _remoteIceCandidates[fromId] ??= [];
        _remoteIceCandidates[fromId]!.add(iceCandidate);

        print('✅ ICE candidate added successfully from: $fromId');
      } else {
        print(
            '📦 Queueing ICE candidate - signaling state not ready: ${peerConnection.signalingState}');
        _queuedIceCandidates[fromId] ??= [];
        _queuedIceCandidates[fromId]!.add(iceCandidate);
      }

      logIceCandidateStats();
    } catch (e) {
      print('❌ Error handling ICE candidate from $fromId: $e');
      log('Error handling ICE candidate from $fromId: $e');
    }
  }

  /// Process queued ICE candidates after remote description is set
  Future<void> _processQueuedIceCandidates(String userId) async {
    final queuedCandidates = _queuedIceCandidates[userId];
    if (queuedCandidates == null || queuedCandidates.isEmpty) {
      print('📦 No queued ICE candidates for user: $userId');
      return;
    }

    print(
        '🔄 Processing ${queuedCandidates.length} queued ICE candidates for user: $userId');

    final peerConnection = _peerConnections[userId];
    if (peerConnection == null) {
      print('❌ No peer connection found for user: $userId');
      return;
    }

    try {
      for (final candidate in queuedCandidates) {
        await peerConnection.addCandidate(candidate);

        // Store for debugging
        _remoteIceCandidates[userId] ??= [];
        _remoteIceCandidates[userId]!.add(candidate);

        print(
            '✅ Processed queued ICE candidate: ${candidate.candidate?.substring(0, 50)}...');
      }

      print(
          '🎉 Successfully processed all ${queuedCandidates.length} queued ICE candidates for user: $userId');
      print(
          '📊 Total remote ICE candidates for $userId: ${_remoteIceCandidates[userId]!.length}');

      // Clear the queue
      _queuedIceCandidates.remove(userId);
    } catch (e) {
      print('❌ Error processing queued ICE candidates for $userId: $e');
    }
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _wsChannel != null) {
      final messageStr = jsonEncode(message);
      _wsChannel!.sink.add(messageStr);
      print('📤 SENT: ${message['type']} to ${message['to'] ?? 'server'}');
      log('Sent message: ${message['type']} to ${message['to'] ?? 'server'}');
    } else {
      print('❌ Cannot send message - WebSocket not connected');
      log('Cannot send message - WebSocket not connected');
      onError?.call('WebSocket connection lost');
    }
  }

  void _handleDisconnection() {
    log('Handling WebSocket disconnection');
    _isConnected = false;
    onDisconnected?.call();
  }

  Future<void> toggleVideo() async {
    try {
      if (_localStream != null) {
        final videoTracks = _localStream!.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          final track = videoTracks.first;
          track.enabled = !track.enabled;
          _isVideoEnabled = track.enabled;
          log('Video toggled: $_isVideoEnabled');

          // Small delay to ensure the toggle is processed
          await Future.delayed(const Duration(milliseconds: 100));
        } else {
          log('No video tracks available to toggle');
        }
      } else {
        log('No local stream available for video toggle');
      }
    } catch (e) {
      log('Error toggling video: $e');
      onError?.call('Failed to toggle video: $e');
    }
  }

  Future<void> toggleAudio() async {
    try {
      if (_localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          final track = audioTracks.first;
          track.enabled = !track.enabled;
          _isAudioEnabled = track.enabled;
          log('Audio toggled: $_isAudioEnabled');

          // Small delay to ensure the toggle is processed
          await Future.delayed(const Duration(milliseconds: 100));
        } else {
          log('No audio tracks available to toggle');
        }
      } else {
        log('No local stream available for audio toggle');
      }
    } catch (e) {
      log('Error toggling audio: $e');
      onError?.call('Failed to toggle audio: $e');
    }
  }

  // Add camera switching functionality
  Future<void> switchCamera() async {
    try {
      if (_localStream != null) {
        final videoTracks = _localStream!.getVideoTracks();
        if (videoTracks.isNotEmpty) {
          final videoTrack = videoTracks.first;
          // Use the flutter_webrtc helper to switch camera
          await videoTrack.switchCamera();
          log('Camera switched successfully');
        } else {
          log('No video tracks available to switch camera');
        }
      } else {
        log('No local stream available for camera switch');
      }
    } catch (e) {
      log('Error switching camera: $e');
      onError?.call('Failed to switch camera: $e');
    }
  }

  // Add method to check camera permission status
  Future<bool> checkCameraPermission() async {
    try {
      // Try to get a temporary stream to check permissions
      final testStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': false,
      });

      // Immediately dispose the test stream
      for (var track in testStream.getTracks()) {
        track.stop();
      }
      testStream.dispose();

      return true;
    } catch (e) {
      log('Camera permission check failed: $e');
      return false;
    }
  }

  // Add method to diagnose video transmission issues
  void diagnoseVideoTransmission() {
    log('=== Video Transmission Diagnosis ===');

    // Check local stream
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      final audioTracks = _localStream!.getAudioTracks();

      log('Local stream: ${videoTracks.length} video tracks, ${audioTracks.length} audio tracks');

      for (var track in videoTracks) {
        log('Local video track: enabled=${track.enabled}, muted=${track.muted}');
      }
    } else {
      log('No local stream available!');
    }

    // Check peer connections
    log('Active peer connections: ${_peerConnections.length}');
    for (var entry in _peerConnections.entries) {
      final participantId = entry.key;
      final pc = entry.value;

      log('Peer $participantId: connectionState=${pc.connectionState}, iceConnectionState=${pc.iceConnectionState}');
    }

    // Check remote streams
    log('Remote streams: ${_remoteStreams.length}');
    for (var entry in _remoteStreams.entries) {
      final participantId = entry.key;
      final stream = entry.value;

      log('Remote stream $participantId: ${stream.getVideoTracks().length} video, ${stream.getAudioTracks().length} audio');
    }

    log('=== End Diagnosis ===');
  }

  // Add method to restart local stream with better error handling
  Future<void> restartLocalStream() async {
    try {
      log('Restarting local stream...');

      // Stop current stream
      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          track.stop();
        }
        await _localStream!.dispose();
        _localStream = null;
      }

      // Wait for camera to be released
      await Future.delayed(const Duration(milliseconds: 1000));

      // Get new stream
      await _getUserMedia();

      // Update peer connections with new stream
      for (var participantId in _peerConnections.keys) {
        final peerConnection = _peerConnections[participantId]!;

        // Remove old tracks
        final senders = await peerConnection.getSenders();
        for (var sender in senders) {
          if (sender.track != null) {
            await peerConnection.removeTrack(sender);
          }
        }

        // Add new tracks
        if (_localStream != null) {
          for (var track in _localStream!.getTracks()) {
            await peerConnection.addTrack(track, _localStream!);
          }
        }
      }

      log('Local stream restarted successfully');
    } catch (e) {
      log('Error restarting local stream: $e');
      onError?.call('Failed to restart local stream: $e');
    }
  }

  Future<void> endCall() async {
    try {
      // Send leave message
      if (_isConnected) {
        _sendMessage({
          'type': 'leave',
        });
      }

      // Close WebSocket connection
      await _wsChannel?.sink.close(status.goingAway);
      _wsChannel = null;
      _isConnected = false;

      // Stop local stream tracks first
      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          track.stop(); // Stop the track first
        }
        await _localStream!.dispose();
        _localStream = null;
        // Wait for camera to be fully released
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Clean up remote streams and renderers
      for (var stream in _remoteStreams.values) {
        for (var track in stream.getTracks()) {
          track.stop(); // Stop remote tracks too
        }
        stream.dispose();
      }
      for (var renderer in _remoteRenderers.values) {
        renderer.dispose();
      }

      // Close peer connections
      for (var peerConnection in _peerConnections.values) {
        peerConnection.close();
      }

      // Clear all data
      _remoteStreams.clear();
      _remoteRenderers.clear();
      _peerConnections.clear();
      _participants.clear();
      _localOffers.clear();
      _localAnswers.clear();
      _remoteOffers.clear();
      _remoteAnswers.clear();
      _localIceCandidates.clear();
      _remoteIceCandidates.clear();
      _queuedIceCandidates.clear(); // Clear queued ICE candidates
      _creatingConnections.clear(); // Clear race condition tracker
      _isCheckingForActiveCall = false;
      _isCallInProgress = false; // Reset the call progress flag

      log('Call ended successfully');
      onDisconnected?.call();
    } catch (e) {
      _isCallInProgress = false; // Always reset the flag
      log('Error ending call: $e');
      onError?.call('Error ending call: $e');
    }
  }

  void dispose() {
    // Dispose the local renderer first
    _localRenderer.dispose();
    // Then end the call which will clean up everything else
    endCall();
  }

  Future<void> _handleExistingPeers(List<dynamic> peerIds) async {
    log('Existing peers: $peerIds');
    print('👥 Processing existing peers: $peerIds');

    for (var peerIdDynamic in peerIds) {
      final peerId = peerIdDynamic.toString();

      // Skip if it's our own ID
      if (peerId == _userId) {
        print('⏭️ Skipping own ID: $peerId');
        continue;
      }

      if (!_participants.contains(peerId)) {
        _participants.add(peerId);
        print('➕ Added participant: $peerId');
      }

      // Create peer connection for existing peer if not already exists
      if (!_peerConnections.containsKey(peerId)) {
        print('🔗 Creating connection to existing peer: $peerId');
        print(
            '   🚀 NEW JOINER SENDS OFFER - we are the offerer to establish connection');
        // CRITICAL FIX: New joiner should send offers to existing peers
        // This ensures bidirectional video connections are established
        await _createConnectionToParticipant(
            peerId, true); // New joiner sends offer
      } else {
        print('✅ Peer connection already exists for: $peerId');
      }
    }

    print('👥 Total active participants: ${_participants.length}');
    print('🔗 Total peer connections: ${_peerConnections.length}');

    // Log detailed peer connection states for debugging
    logPeerConnectionStates();

    onParticipantsChanged?.call(_participants);
  }

  // Add comprehensive diagnostic function
  Future<void> runVideoTransmissionDiagnostics(String participantId) async {
    log('=== VIDEO TRANSMISSION DIAGNOSTICS for $participantId ===');

    // Check local stream
    if (_localStream == null) {
      log('❌ No local stream available');
      return;
    }

    final videoTracks = _localStream!.getVideoTracks();
    log('📹 Local video tracks: ${videoTracks.length}');
    for (var track in videoTracks) {
      log('  - Track: ${track.id}, enabled: ${track.enabled}, kind: ${track.kind}');
      log('  - Muted: ${track.muted}');
    }

    // Check peer connection
    final peerConnection = _peerConnections[participantId];
    if (peerConnection == null) {
      log('❌ No peer connection for $participantId');
      return;
    }

    log('🔗 Peer connection state: ${peerConnection.connectionState}');
    log('🧊 ICE connection state: ${peerConnection.iceConnectionState}');
    log('📡 ICE gathering state: ${peerConnection.iceGatheringState}');
    log('🔧 Signaling state: ${peerConnection.signalingState}');

    // Check senders
    try {
      final senders = await peerConnection.getSenders();
      log('📤 Senders: ${senders.length}');
      for (var sender in senders) {
        if (sender.track != null) {
          log('  - Sender track: ${sender.track!.kind}, enabled: ${sender.track!.enabled}');
        } else {
          log('  - Sender has no track');
        }
      }
    } catch (e) {
      log('❌ Error getting senders: $e');
    }

    // Check receivers
    try {
      final receivers = await peerConnection.getReceivers();
      log('📥 Receivers: ${receivers.length}');
      for (var receiver in receivers) {
        if (receiver.track != null) {
          log('  - Receiver track: ${receiver.track!.kind}, enabled: ${receiver.track!.enabled}');
        } else {
          log('  - Receiver has no track');
        }
      }
    } catch (e) {
      log('❌ Error getting receivers: $e');
    }

    // Check remote stream
    final remoteStream = _remoteStreams[participantId];
    if (remoteStream == null) {
      log('❌ No remote stream for $participantId');
    } else {
      final remoteVideoTracks = remoteStream.getVideoTracks();
      log('📹 Remote video tracks: ${remoteVideoTracks.length}');
      for (var track in remoteVideoTracks) {
        log('  - Remote track: ${track.id}, enabled: ${track.enabled}, kind: ${track.kind}');
        log('  - Muted: ${track.muted}');
      }
    }

    // Check renderer
    final renderer = _remoteRenderers[participantId];
    if (renderer == null) {
      log('❌ No renderer for $participantId');
    } else {
      log('🖥️ Renderer available, srcObject: ${renderer.srcObject != null}');
      if (renderer.srcObject != null) {
        log('  - Renderer stream ID: ${renderer.srcObject!.id}');
      }
    }

    log('=== END DIAGNOSTICS ===');
  }

  // Add this method to help debug the call setup
  Future<void> debugCallSetup() async {
    log('🔍 === CALL SETUP DEBUG ===');

    // Check WebSocket connection
    log('🌐 WebSocket connected: $_isConnected');
    log('👤 User ID: $_userId');

    // Check local stream
    if (_localStream == null) {
      log('❌ No local stream');
    } else {
      log('📹 Local stream: ${_localStream!.id}');
      log('📹 Video tracks: ${_localStream!.getVideoTracks().length}');
      log('🎤 Audio tracks: ${_localStream!.getAudioTracks().length}');
    }

    // Check participants
    log('👥 Participants: $_participants');
    log('🔗 Peer connections: ${_peerConnections.keys.toList()}');
    for (var participantId in _peerConnections.keys) {
      final pc = _peerConnections[participantId]!;
      final localDesc = await pc.getLocalDescription();
      final remoteDesc = await pc.getRemoteDescription();
      log('  - $participantId: local=${localDesc?.type}, remote=${remoteDesc?.type}');
    }

    // Check ICE candidates
    log('❄️ ICE Candidates:');
    log('  📦 Local ICE candidates: ${_localIceCandidates.length}');
    log('  📦 Remote ICE candidates: ${_remoteIceCandidates.length}');
    log('  📦 Queued ICE candidates: ${_queuedIceCandidates.length}');

    for (var participantId in _participants) {
      final localCandidates = _localIceCandidates[participantId]?.length ?? 0;
      final remoteCandidates = _remoteIceCandidates[participantId]?.length ?? 0;
      final queuedCandidates = _queuedIceCandidates[participantId]?.length ?? 0;
      log('  - $participantId: local=$localCandidates, remote=$remoteCandidates, queued=$queuedCandidates');
    }

    log('=== END CALL SETUP DEBUG ===');
  }

  /// Debug method to show ICE candidate statistics
  void logIceCandidateStats() {
    print('🔍 ICE Candidate Statistics:');
    print('  📊 Local ICE candidates:');
    _localIceCandidates.forEach((userId, candidates) {
      print('    $userId: ${candidates.length} candidates');
    });

    print('  📊 Remote ICE candidates:');
    _remoteIceCandidates.forEach((userId, candidates) {
      print('    $userId: ${candidates.length} candidates');
    });

    print('  📦 Queued ICE candidates:');
    _queuedIceCandidates.forEach((userId, candidates) {
      print('    $userId: ${candidates.length} queued candidates');
    });

    print('  🔗 Active peer connections: ${_peerConnections.length}');
    _peerConnections.forEach((userId, connection) async {
      final localDesc = await connection.getLocalDescription();
      final remoteDesc = await connection.getRemoteDescription();
      print(
          '    $userId: local=${localDesc?.type}, remote=${remoteDesc?.type}');
    });
  }

  /// Debug method to track peer connection establishment
  void logPeerConnectionStates() {
    print('🔍 PEER CONNECTION STATES:');
    print('  👥 Total participants: ${_participants.length}');
    print('  🔗 Total peer connections: ${_peerConnections.length}');
    print('  🚧 Connections being created: ${_creatingConnections.length}');

    for (var participantId in _participants) {
      final hasConnection = _peerConnections.containsKey(participantId);
      final isCreating = _creatingConnections.containsKey(participantId);

      print(
          '  📊 $participantId: connection=$hasConnection, creating=$isCreating');

      if (hasConnection) {
        final pc = _peerConnections[participantId]!;
        print('    - Connection state: ${pc.connectionState}');
        print('    - ICE state: ${pc.iceConnectionState}');
        print('    - Signaling state: ${pc.signalingState}');

        // Check if we have remote stream
        final hasRemoteStream = _remoteStreams.containsKey(participantId);
        final hasRenderer = _remoteRenderers.containsKey(participantId);
        print('    - Remote stream: $hasRemoteStream, renderer: $hasRenderer');

        if (hasRemoteStream) {
          final stream = _remoteStreams[participantId]!;
          print('    - Remote video tracks: ${stream.getVideoTracks().length}');
          print('    - Remote audio tracks: ${stream.getAudioTracks().length}');
        }
      }
    }
  }

  /// Check if we're actually sending tracks to remote peers
  Future<void> checkOutgoingTracks() async {
    print('🔍 CHECKING OUTGOING TRACKS:');

    if (_localStream == null) {
      print('❌ No local stream available');
      return;
    }

    print('📹 Local stream tracks:');
    for (var track in _localStream!.getTracks()) {
      print(
          '  - ${track.kind}: ${track.id} (enabled: ${track.enabled}, muted: ${track.muted})');
    }

    for (var participantId in _peerConnections.keys) {
      print('📡 Checking outgoing tracks for $participantId:');
      final pc = _peerConnections[participantId]!;

      try {
        final senders = await pc.getSenders();
        print('  - Total senders: ${senders.length}');

        for (var sender in senders) {
          if (sender.track != null) {
            print(
                '    - Sending ${sender.track!.kind}: ${sender.track!.id} (enabled: ${sender.track!.enabled})');
          } else {
            print('    - Sender with null track');
          }
        }

        final receivers = await pc.getReceivers();
        print('  - Total receivers: ${receivers.length}');

        for (var receiver in receivers) {
          if (receiver.track != null) {
            print(
                '    - Receiving ${receiver.track!.kind}: ${receiver.track!.id} (enabled: ${receiver.track!.enabled})');
          } else {
            print('    - Receiver with null track');
          }
        }
      } catch (e) {
        print('  - Error checking tracks: $e');
      }
    }
  }

  /// Force check all track events and streams manually
  Future<void> debugTrackEvents() async {
    print('🔍 === MANUAL TRACK EVENT DEBUG ===');

    print('📊 Current state:');
    print('  - Participants: ${_participants.length}');
    print('  - Peer connections: ${_peerConnections.length}');
    print('  - Remote streams: ${_remoteStreams.length}');
    print('  - Remote renderers: ${_remoteRenderers.length}');

    for (var participantId in _participants) {
      print('🎯 Checking $participantId:');

      final hasConnection = _peerConnections.containsKey(participantId);
      final hasStream = _remoteStreams.containsKey(participantId);
      final hasRenderer = _remoteRenderers.containsKey(participantId);

      print('  - Has connection: $hasConnection');
      print('  - Has remote stream: $hasStream');
      print('  - Has renderer: $hasRenderer');

      if (hasConnection) {
        final pc = _peerConnections[participantId]!;
        print('  - Connection state: ${pc.connectionState}');
        print('  - ICE state: ${pc.iceConnectionState}');
        print('  - Signaling state: ${pc.signalingState}');

        try {
          final receivers = await pc.getReceivers();
          print('  - Receivers: ${receivers.length}');

          for (var receiver in receivers) {
            if (receiver.track != null) {
              print(
                  '    - Receiver track: ${receiver.track!.kind} (enabled: ${receiver.track!.enabled})');
            }
          }
        } catch (e) {
          print('  - Error checking receivers: $e');
        }
      }

      if (hasStream) {
        final stream = _remoteStreams[participantId]!;
        print('  - Stream video tracks: ${stream.getVideoTracks().length}');
        print('  - Stream audio tracks: ${stream.getAudioTracks().length}');
      }
    }
  }
}
