// import 'package:flutter/material.dart';

// import 'services/secure_storage_service.dart';

// class UsernamePage extends StatefulWidget {
//   const UsernamePage({super.key});

//   @override
//   State<UsernamePage> createState() => _UsernamePageState();
// }

// class _UsernamePageState extends State<UsernamePage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final SecureStorageService _storageService = SecureStorageService();
//   bool _isUsernameValid = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsername();
//   }

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     super.dispose();
//   }

//   // Load username if previously saved
//   Future<void> _loadUsername() async {
//     final savedUsername = await _storageService.getUsername();

//     if (savedUsername != null) {
//       setState(() {
//         _usernameController.text = savedUsername;
//         _isUsernameValid = savedUsername.length >= 3;
//       });
//     }
//   }

//   void _validateUsername(String value) {
//     setState(() {
//       _isUsernameValid = value.length >= 3;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 60),
//               Text(
//                 'Create username',
//                 style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Choose a username for your new account',
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       color: Colors.black54,
//                     ),
//               ),
//               const SizedBox(height: 40),
//               TextField(
//                 controller: _usernameController,
//                 onChanged: _validateUsername,
//                 decoration: InputDecoration(
//                   // labelText: 'Username',
//                   hintText: 'Enter username',
//                   prefixIcon: const Icon(Icons.person_outline),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
//                   errorText: _isUsernameValid
//                       ? null
//                       : 'Username must be at least 3 characters',
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () async {
//                           if (_usernameController.text.length >= 3) {
//                             setState(() {
//                               _isLoading = true;
//                             });

//                             try {
//                               // Save username using the service
//                               final success = await _storageService
//                                   .saveUsername(_usernameController.text);

//                               if (!mounted) return;

//                               if (success) {
//                                 print(
//                                     'Username "${_usernameController.text}" saved securely!');
//                                 // ScaffoldMessenger.of(context).showSnackBar(
//                                 //   SnackBar(
//                                 //     content: Text(
//                                 //         'Username "${_usernameController.text}" saved securely!'),
//                                 //     backgroundColor: Colors.green,
//                                 //   ),
//                                 // );
//                                 // Navigate to next screen or perform additional actions
//                                 Navigator.of(context)
//                                     .pushReplacementNamed('/splashpage');
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Failed to save username'),
//                                     backgroundColor: Colors.red,
//                                   ),
//                                 );
//                               }
//                             } catch (e) {
//                               if (!mounted) return;
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text('Error: $e'),
//                                   backgroundColor: Colors.red,
//                                 ),
//                               );
//                             } finally {
//                               if (mounted) {
//                                 setState(() {
//                                   _isLoading = false;
//                                 });
//                               }
//                             }
//                           } else {
//                             setState(() {
//                               _isUsernameValid = false;
//                             });
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).primaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2.0,
//                           ),
//                         )
//                       : const Text(
//                           'Continue',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
