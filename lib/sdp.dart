// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'webrtc/api/webrtc_service.dart';

// class SdpView extends StatefulWidget {
//   final WebRTCService? webrtcService;

//   const SdpView({super.key, this.webrtcService});

//   @override
//   State<SdpView> createState() => _SdpViewState();
// }

// class _SdpViewState extends State<SdpView> with TickerProviderStateMixin {
//   WebRTCService? _webrtcService;
//   String? _localOfferSdp;
//   String? _localAnswerSdp;
//   String? _remoteOfferSdp;
//   String? _remoteAnswerSdp;
//   late TabController _tabController;
//   bool _isInitialized = false;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this); // Updated to 6 tabs
//     _webrtcService = widget.webrtcService;

//     if (_webrtcService != null) {
//       // Use existing service and load current SDP data
//       _isInitialized = true;
//       _loadCurrentSdpData();
//     } else {
//       // Create new service for SDP viewing only
//       _webrtcService = WebRTCService();
//       _initializeWebRTC();
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     // Only dispose if we created the service (not passed from outside)
//     if (widget.webrtcService == null) {
//       _webrtcService?.dispose();
//     }
//     super.dispose();
//   }

//   void _loadCurrentSdpData() {
//     setState(() {
//       _localOfferSdp = _webrtcService?.localOfferSdp;
//       _localAnswerSdp = _webrtcService?.localAnswerSdp;
//       _remoteOfferSdp = _webrtcService?.remoteOfferSdp;
//       _remoteAnswerSdp = _webrtcService?.remoteAnswerSdp;
//     });
//   }

//   Future<void> _initializeWebRTC() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _webrtcService!.initialize();
//       setState(() {
//         _isInitialized = true;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error initializing WebRTC: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _generateOfferSdp() async {
//     if (!_isInitialized || _webrtcService == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Start a test call to generate SDP data (without actually making a call)
//       await _webrtcService!.initialize();

//       // Initialize the WebSocket connection and join for debugging
//       await _webrtcService!.startCall(videoEnabled: true, audioEnabled: true);

//       // Wait a moment for SDP generation
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Get the local offer SDP
//       setState(() {
//         _localOfferSdp = _webrtcService!.localOfferSdp ??
//             'SDP will be generated when peers connect. Start a call first.';
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error generating offer SDP: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _generateAnswerSdp() async {
//     if (!_isInitialized || _localOfferSdp == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       setState(() {
//         _localAnswerSdp = 'To generate an answer SDP, you need to:\n'
//             '1. Use the generated offer SDP above\n'
//             '2. Send it to another peer or join a room\n'
//             '3. The answer SDP will be created automatically when another peer responds\n\n'
//             'This is part of the WebRTC signaling process where:\n'
//             '- Caller creates an offer SDP\n'
//             '- Callee receives the offer and creates an answer SDP\n'
//             '- Both peers exchange these SDPs to establish connection';
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error generating answer SDP: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _refreshSdpData() {
//     if (_webrtcService != null) {
//       _loadCurrentSdpData();
//     } else {
//       setState(() {
//         _localOfferSdp = 'SDP data available in console logs';
//         _localAnswerSdp = 'SDP data available in console logs';
//         _remoteOfferSdp = 'SDP data available in console logs';
//         _remoteAnswerSdp = 'SDP data available in console logs';
//       });
//     }
//   }

//   void _copyToClipboard(String text) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('SDP copied to clipboard'),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   Widget _buildSdpCard(String title, String? sdp, VoidCallback? onGenerate) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 if (onGenerate != null)
//                   ElevatedButton.icon(
//                     onPressed: _isLoading ? null : onGenerate,
//                     icon: _isLoading
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.refresh),
//                     label: Text(_isLoading ? 'Generating...' : 'Generate'),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (sdp != null) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'SDP Content:',
//                           style:
//                               Theme.of(context).textTheme.titleSmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                         ),
//                         IconButton(
//                           onPressed: () => _copyToClipboard(sdp),
//                           icon: const Icon(Icons.copy, size: 20),
//                           tooltip: 'Copy to clipboard',
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       constraints: const BoxConstraints(maxHeight: 300),
//                       child: SingleChildScrollView(
//                         child: Text(
//                           sdp,
//                           style: const TextStyle(
//                             fontFamily: 'monospace',
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildSdpAnalysis(sdp),
//             ] else
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[200]!),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       size: 48,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No SDP available',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       onGenerate != null
//                           ? 'Click Generate to create SDP'
//                           : 'SDP will appear here when available',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Colors.grey[500],
//                           ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSdpAnalysis(String sdp) {
//     final hasVideo = sdp.contains('m=video');
//     final hasAudio = sdp.contains('m=audio');
//     final hasDataChannel = sdp.contains('m=application');

//     // Extract codec information
//     final videoCodecs = <String>[];
//     final audioCodecs = <String>[];

//     final lines = sdp.split('\n');
//     for (var i = 0; i < lines.length; i++) {
//       final line = lines[i].trim();
//       if (line.startsWith('a=rtpmap:')) {
//         final parts = line.split(' ');
//         if (parts.length > 1) {
//           final codec = parts[1].split('/')[0];
//           if (i > 0 && lines[i - 1].contains('m=video')) {
//             videoCodecs.add(codec);
//           } else if (i > 0 && lines[i - 1].contains('m=audio')) {
//             audioCodecs.add(codec);
//           }
//         }
//       }
//     }

//     return Card(
//       color: Colors.blue[50],
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'SDP Analysis',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 _buildAnalysisChip('Video', hasVideo, Colors.green),
//                 const SizedBox(width: 8),
//                 _buildAnalysisChip('Audio', hasAudio, Colors.blue),
//                 const SizedBox(width: 8),
//                 _buildAnalysisChip(
//                     'Data Channel', hasDataChannel, Colors.orange),
//               ],
//             ),
//             if (videoCodecs.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Text(
//                 'Video Codecs: ${videoCodecs.join(', ')}',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//             if (audioCodecs.isNotEmpty) ...[
//               const SizedBox(height: 4),
//               Text(
//                 'Audio Codecs: ${audioCodecs.join(', ')}',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnalysisChip(String label, bool isPresent, Color color) {
//     return Chip(
//       label: Text(
//         label,
//         style: TextStyle(
//           color: isPresent ? Colors.white : Colors.grey[600],
//           fontSize: 12,
//         ),
//       ),
//       backgroundColor: isPresent ? color : Colors.grey[200],
//       side: BorderSide.none,
//     );
//   }

//   Widget _buildIceCandidateCard(String title, List<dynamic> candidates) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 Chip(
//                   label: Text('${candidates.length} candidates'),
//                   backgroundColor:
//                       candidates.isEmpty ? Colors.grey[200] : Colors.green[100],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (candidates.isEmpty) ...[
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: const Text(
//                   'No ICE candidates available yet.\n\nICE candidates are generated during the WebRTC connection process and are used to establish the peer-to-peer connection.',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ),
//             ] else ...[
//               ...candidates.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final candidate = entry.value;
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: Card(
//                     color: Colors.blue[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Candidate ${index + 1}',
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleSmall
//                                     ?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                               IconButton(
//                                 onPressed: () =>
//                                     _copyToClipboard(candidate.candidate ?? ''),
//                                 icon: const Icon(Icons.copy, size: 16),
//                                 tooltip: 'Copy candidate',
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Candidate: ${candidate.candidate ?? 'N/A'}',
//                             style: const TextStyle(
//                               fontFamily: 'monospace',
//                               fontSize: 11,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'SDP Mid: ${candidate.sdpMid ?? 'N/A'}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           Text(
//                             'SDP MLine Index: ${candidate.sdpMLineIndex ?? 'N/A'}',
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SDP Viewer'),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           tabs: const [
//             Tab(text: 'Local Offer', icon: Icon(Icons.call_made)),
//             Tab(text: 'Local Answer', icon: Icon(Icons.call_received)),
//             Tab(text: 'Remote Offer', icon: Icon(Icons.cloud_download)),
//             Tab(text: 'Remote Answer', icon: Icon(Icons.cloud_upload)),
//             Tab(text: 'Local ICE', icon: Icon(Icons.network_cell)),
//             Tab(text: 'Remote ICE', icon: Icon(Icons.network_wifi)),
//           ],
//         ),
//       ),
//       body: !_isInitialized && _isLoading
//           ? const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Initializing WebRTC...'),
//                 ],
//               ),
//             )
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 SingleChildScrollView(
//                   child: _buildSdpCard(
//                     'Local Offer SDP',
//                     _localOfferSdp,
//                     _generateOfferSdp,
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: _buildSdpCard(
//                     'Local Answer SDP',
//                     _localAnswerSdp,
//                     _localOfferSdp != null ? _generateAnswerSdp : null,
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: _buildSdpCard(
//                     'Remote Offer SDP',
//                     _remoteOfferSdp,
//                     null,
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: _buildSdpCard(
//                     'Remote Answer SDP',
//                     _remoteAnswerSdp,
//                     null,
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: _buildIceCandidateCard(
//                     'Local ICE Candidates',
//                     _webrtcService?.localIceCandidates.values
//                         .expand((candidates) => candidates)
//                         .toList() ?? [],
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: _buildIceCandidateCard(
//                     'Remote ICE Candidates',
//                     _webrtcService?.remoteIceCandidates.values
//                         .expand((candidates) => candidates)
//                         .toList() ?? [],
//                   ),
//                 ),
//               ],
//             ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: "refresh",
//             onPressed: _refreshSdpData,
//             tooltip: 'Refresh SDP Data',
//             mini: true,
//             child: const Icon(Icons.refresh),
//           ),
//           const SizedBox(height: 8),
//           FloatingActionButton(
//             heroTag: "clear",
//             onPressed: () {
//               setState(() {
//                 _localOfferSdp = null;
//                 _localAnswerSdp = null;
//                 _remoteOfferSdp = null;
//                 _remoteAnswerSdp = null;
//               });
//             },
//             tooltip: 'Clear All SDP',
//             child: const Icon(Icons.clear_all),
//           ),
//         ],
//       ),
//     );
//   }
// }
