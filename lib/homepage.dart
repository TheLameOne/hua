// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:grpc/grpc.dart';
// import 'package:hua/proto/generated/bidirectional.pbgrpc.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   @override
//   void initState() {
//     super.initState();
//     _functions();
//   }

//   void _functions() async {
//     try {
//       final channel = ClientChannel('69.62.77.227',
//           port: 8080,
//           options:
//               const ChannelOptions(credentials: ChannelCredentials.insecure()));

//       print('Connecting to ${channel.host}:${channel.port}');

//       final stub = BidirectionalClient(channel,
//           options: CallOptions(timeout: Duration(seconds: 30)));

//       print('Created stub: $stub');

//       // Create a request controller
//       final requestController = StreamController<Request>();

//       // Get the response stream by passing the request controller's stream
//       final responseStream = stub.chatty(requestController.stream);
//       print('Stream created');

//       // Listen for responses
//       responseStream.listen(
//         (response) {
//           print('Received: ${response.userName}: ${response.responseMessage}');
//         },
//         onError: (error) {
//           print('Error: $error');
//         },
//         onDone: () {
//           print('Stream closed');
//         },
//       );

//       // First message must be the username (matching Go client pattern)
//       final usernameRequest = Request()..userName = "FlutterUser";
//       requestController.add(usernameRequest);
//       print('Username sent: FlutterUser');

//       final chatMessage = Request()..clientMessage = "Hello";

//       for (int i = 0; i < 100; i++) {
//         requestController.add(chatMessage);
//       }

//       // Send a test message after username
//       // await Future.delayed(Duration(seconds: 2));
//       final messageRequest = Request()..clientMessage = "Hello from Flutter!";
//       requestController.add(messageRequest);
//       // print('Message sent: Hello from Flutter!');

//       // Keep connection alive - don't close the controller immediately
//       // In a real app, you'd close this when appropriate
//       // await requestController.close();
//     } catch (e) {
//       print('Error in gRPC communication: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Text("Hello"),
//       ),
//     );
//   }
// }
