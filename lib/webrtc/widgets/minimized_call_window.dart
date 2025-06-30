import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../providers/webrtc_provider.dart';

class MinimizedCallWindow extends StatefulWidget {
  final bool isVideoCall;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const MinimizedCallWindow({
    super.key,
    required this.isVideoCall,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<MinimizedCallWindow> createState() => _MinimizedCallWindowState();
}

class _MinimizedCallWindowState extends State<MinimizedCallWindow> {
  Offset position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              (position.dx + details.delta.dx)
                  .clamp(0, MediaQuery.of(context).size.width - 120),
              (position.dy + details.delta.dy)
                  .clamp(0, MediaQuery.of(context).size.height - 160),
            );
          });
        },
        onTap: widget.onTap,
        child: Consumer<WebRTCProvider>(
          builder: (context, provider, child) {
            return Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF25D366),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background
                    Container(
                      color: const Color(0xFF0B141B),
                    ),

                    // Video content
                    if (widget.isVideoCall && provider.isVideoEnabled)
                      RTCVideoView(
                        provider.webrtcService.localRenderer,
                        mirror: true,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    else
                      // Audio call or video disabled
                      Container(
                        color: const Color(0xFF0B141B),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF25D366),
                          ),
                        ),
                      ),

                    // Overlay with call info
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),

                    // Call status
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.isVideoCall ? 'Video' : 'Voice',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          // End the call through provider
                          await provider.endCall();
                          widget.onClose();
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53E3E),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),

                    // Call controls at bottom
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mic toggle
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              provider.toggleAudio();
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: provider.isAudioEnabled
                                    ? const Color(0xFF1F2937)
                                    : const Color(0xFFE53E3E),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                provider.isAudioEnabled
                                    ? Icons.mic
                                    : Icons.mic_off,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),

                          // Video toggle (only for video calls)
                          if (widget.isVideoCall)
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                provider.toggleVideo();
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: provider.isVideoEnabled
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFE53E3E),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  provider.isVideoEnabled
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
