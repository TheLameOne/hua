// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:provider/provider.dart';
// import '../providers/webrtc_provider.dart';

// class WebRTCView extends StatefulWidget {
//   final String roomId;
//   final bool isVideoCall;

//   const WebRTCView({
//     super.key,
//     required this.roomId,
//     this.isVideoCall = true,
//   });

//   @override
//   State<WebRTCView> createState() => _WebRTCViewState();
// }

// class _WebRTCViewState extends State<WebRTCView> with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Initialize pulse animation for connecting state
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(
//       begin: 0.3,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _pulseController.repeat(reverse: true);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _startCall();
//     });
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   void _startCall() async {
//     final provider = context.read<WebRTCProvider>();
//     try {
//       if (widget.isVideoCall) {
//         await provider.startVideoCall(widget.roomId);
//       } else {
//         await provider.startVoiceCall(widget.roomId);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to start call: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0B141B), // WhatsApp dark background
//       body: Consumer<WebRTCProvider>(
//         builder: (context, provider, child) {
//           switch (provider.callState) {
//             case CallState.connecting:
//               return _buildConnectingView();
//             case CallState.connected:
//               return _buildCallView(provider);
//             case CallState.error:
//               return _buildErrorView(provider);
//             default:
//               return _buildConnectingView();
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildConnectingView() {
//     return Container(
//       color: const Color(0xFF0B141B),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // WhatsApp-style header
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     widget.isVideoCall ? 'Video calling...' : 'Calling...',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Profile picture placeholder
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFF25D366).withValues(alpha: 0.2),
//                       border: Border.all(
//                         color: const Color(0xFF25D366),
//                         width: 2,
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.person,
//                       size: 60,
//                       color: Color(0xFF25D366),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Just call type without room number
//                   Text(
//                     widget.isVideoCall ? 'Video Call' : 'Voice Call',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   AnimatedBuilder(
//                     animation: _pulseAnimation,
//                     builder: (context, child) {
//                       return Opacity(
//                         opacity: _pulseAnimation.value.clamp(0.0, 1.0),
//                         child: Text(
//                           widget.isVideoCall
//                               ? 'Video calling...'
//                               : 'Calling...',
//                           style: const TextStyle(
//                             color: Color(0xFF8FADBD),
//                             fontSize: 16,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // End call button
//             Padding(
//               padding: const EdgeInsets.only(bottom: 50),
//               child: FloatingActionButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 backgroundColor: const Color(0xFFE53E3E),
//                 child: const Icon(
//                   Icons.call_end,
//                   color: Colors.white,
//                   size: 28,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorView(WebRTCProvider provider) {
//     return Container(
//       color: const Color(0xFF0B141B),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Call Failed',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Error icon
//                   Container(
//                     width: 120,
//                     height: 120,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFFE53E3E).withValues(alpha: 0.2),
//                       border: Border.all(
//                         color: const Color(0xFFE53E3E),
//                         width: 2,
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.call_end,
//                       size: 60,
//                       color: Color(0xFFE53E3E),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   const Text(
//                     'Call couldn\'t connect',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 40),
//                     child: Text(
//                       provider.errorMessage ??
//                           'Please check your internet connection and try again',
//                       style: const TextStyle(
//                         color: Color(0xFF8FADBD),
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Action buttons
//             Padding(
//               padding: const EdgeInsets.only(bottom: 50),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Call again button
//                   FloatingActionButton(
//                     onPressed: () {
//                       HapticFeedback.lightImpact();
//                       provider.clearError();
//                       _startCall();
//                     },
//                     backgroundColor: const Color(0xFF25D366),
//                     child: Icon(
//                       widget.isVideoCall ? Icons.videocam : Icons.call,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),

//                   // End call button
//                   FloatingActionButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     backgroundColor: const Color(0xFFE53E3E),
//                     child: const Icon(
//                       Icons.call_end,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCallView(WebRTCProvider provider) {
//     final remoteRenderers = provider.webrtcService.remoteRenderers;

//     return Container(
//       color: const Color(0xFF0B141B),
//       child: SafeArea(
//         child: Stack(
//           children: [
//             // Main content area
//             if (widget.isVideoCall) ...[
//               _buildVideoGrid(remoteRenderers, provider),
//               // Local video preview
//               _buildLocalVideoPreview(provider),
//             ] else ...[
//               _buildVoiceCallView(provider),
//             ],

//             // Top bar with back button and status
//             _buildTopBar(provider),

//             // Call controls
//             _buildCallControls(provider),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoGrid(
//       Map<String, RTCVideoRenderer> remoteRenderers, WebRTCProvider provider) {
//     if (remoteRenderers.isEmpty) {
//       return Column(
//         children: [
//           const SizedBox(height: 100), // Space for top bar
//           Expanded(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Profile placeholder
//                   Container(
//                     width: 150,
//                     height: 150,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFF25D366).withValues(alpha: 0.2),
//                       border: Border.all(
//                         color: const Color(0xFF25D366),
//                         width: 3,
//                       ),
//                     ),
//                     child: const Icon(
//                       Icons.person,
//                       size: 80,
//                       color: Color(0xFF25D366),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   Text(
//                     widget.isVideoCall ? 'Video Call' : 'Voice Call',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   const Text(
//                     'Waiting for others to join...',
//                     style: TextStyle(
//                       color: Color(0xFF8FADBD),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     final count = remoteRenderers.length;
//     int crossAxisCount = count == 1
//         ? 1
//         : count <= 4
//             ? 2
//             : 3;

//     return Column(
//       children: [
//         const SizedBox(height: 80), // Space for top bar
//         Expanded(
//           child: GridView.builder(
//             padding: const EdgeInsets.all(8),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               childAspectRatio: 16 / 9,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: remoteRenderers.length,
//             itemBuilder: (context, index) {
//               final participantId = remoteRenderers.keys.elementAt(index);
//               final renderer = remoteRenderers.values.elementAt(index);

//               return Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: const Color(0xFF25D366).withValues(alpha: 0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       RTCVideoView(
//                         renderer,
//                         objectFit:
//                             RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                       ),
//                       // Participant label
//                       Positioned(
//                         bottom: 8,
//                         left: 8,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withValues(alpha: 0.7),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             'User ${participantId.substring(participantId.length - 4)}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLocalVideoPreview(WebRTCProvider provider) {
//     if (!widget.isVideoCall || !provider.isVideoEnabled) {
//       return const SizedBox.shrink();
//     }

//     return Positioned(
//       top: 90,
//       right: 16,
//       child: GestureDetector(
//         onTap: () {
//           HapticFeedback.lightImpact();
//           // Could add functionality to switch views
//         },
//         child: Container(
//           width: 100,
//           height: 140,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: const Color(0xFF25D366),
//               width: 2,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 RTCVideoView(
//                   provider.webrtcService.localRenderer,
//                   mirror: true,
//                   objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
//                 ),
//                 // "You" label
//                 Positioned(
//                   bottom: 4,
//                   left: 4,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withValues(alpha: 0.7),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       'You',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 9,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVoiceCallView(WebRTCProvider provider) {
//     return Column(
//       children: [
//         const SizedBox(height: 100), // Space for top bar
//         Expanded(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Large profile picture
//                 Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: const Color(0xFF25D366).withValues(alpha: 0.2),
//                     border: Border.all(
//                       color: const Color(0xFF25D366),
//                       width: 3,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     size: 100,
//                     color: Color(0xFF25D366),
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 Text(
//                   widget.isVideoCall ? 'Video Call' : 'Voice Call',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.w300,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   'WhatsApp Voice Call',
//                   style: TextStyle(
//                     color: Color(0xFF8FADBD),
//                     fontSize: 16,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Call duration could be added here
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.3),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: const Color(0xFF25D366).withValues(alpha: 0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     '${provider.participants.length + 1} participant${provider.participants.length + 1 != 1 ? 's' : ''}',
//                     style: const TextStyle(
//                       color: Color(0xFF8FADBD),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCallControls(WebRTCProvider provider) {
//     return Positioned(
//       bottom: 30,
//       left: 0,
//       right: 0,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           // Audio toggle
//           _buildWhatsAppButton(
//             onPressed: () {
//               HapticFeedback.mediumImpact();
//               provider.toggleAudio();
//             },
//             icon: provider.isAudioEnabled ? Icons.mic : Icons.mic_off,
//             backgroundColor: provider.isAudioEnabled
//                 ? const Color(0xFF1F2937)
//                 : const Color(0xFFE53E3E),
//             size: 60,
//           ),

//           // End call
//           _buildWhatsAppButton(
//             onPressed: () async {
//               HapticFeedback.heavyImpact();
//               await provider.endCall();
//               if (mounted) {
//                 Navigator.of(context).pop();
//               }
//             },
//             icon: Icons.call_end,
//             backgroundColor: const Color(0xFFE53E3E),
//             size: 70,
//             iconSize: 32,
//           ),

//           // Video toggle or speaker toggle
//           if (widget.isVideoCall)
//             _buildWhatsAppButton(
//               onPressed: () {
//                 HapticFeedback.mediumImpact();
//                 provider.toggleVideo();
//               },
//               icon:
//                   provider.isVideoEnabled ? Icons.videocam : Icons.videocam_off,
//               backgroundColor: provider.isVideoEnabled
//                   ? const Color(0xFF1F2937)
//                   : const Color(0xFFE53E3E),
//               size: 60,
//             )
//           else
//             _buildWhatsAppButton(
//               onPressed: () {
//                 HapticFeedback.mediumImpact();
//                 // Add speaker toggle functionality
//               },
//               icon: Icons.volume_up,
//               backgroundColor: const Color(0xFF1F2937),
//               size: 60,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWhatsAppButton({
//     required VoidCallback onPressed,
//     required IconData icon,
//     required Color backgroundColor,
//     double size = 56,
//     double iconSize = 24,
//   }) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(size / 2),
//           child: Center(
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: iconSize,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar(WebRTCProvider provider) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.black.withValues(alpha: 0.8),
//               Colors.transparent,
//             ],
//           ),
//         ),
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () => Navigator.of(context).pop(),
//               icon: const Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     widget.isVideoCall ? 'Video Call' : 'Voice Call',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   Text(
//                     '${provider.participants.length + 1} participant${provider.participants.length + 1 != 1 ? 's' : ''}',
//                     style: const TextStyle(
//                       color: Color(0xFF8FADBD),
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Connection status
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF25D366).withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 6,
//                     height: 6,
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF25D366),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   const Text(
//                     'Connected',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
