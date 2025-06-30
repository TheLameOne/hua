import 'package:flutter/material.dart';
import '../widgets/minimized_call_window.dart';
import '../views/webrtc_view.dart';

class CallOverlayManager {
  static OverlayEntry? _overlayEntry;
  static bool _isMinimized = false;

  static bool _isVideoCall = true;

  static bool get isMinimized => _isMinimized;
  static bool get hasActiveCall => _overlayEntry != null;

  static void showMinimizedCall({
    required BuildContext context,
    required bool isVideoCall,
  }) {
    if (_overlayEntry != null) {
      hideMinimizedCall();
    }

    _isVideoCall = isVideoCall;
    _isMinimized = true;

    _overlayEntry = OverlayEntry(
      builder: (context) => MinimizedCallWindow(
        isVideoCall: isVideoCall,
        onTap: () => _expandCall(context),
        onClose: () => _endCall(context),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hideMinimizedCall() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isMinimized = false;
    }
  }

  static void _expandCall(BuildContext context) {
    hideMinimizedCall();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebRTCView(
          isVideoCall: _isVideoCall,
        ),
      ),
    );
  }

  static void _endCall(BuildContext context) {
    // Just hide the minimized call overlay
    // The actual call ending is handled by the provider in the widget
    hideMinimizedCall();
  }
}
