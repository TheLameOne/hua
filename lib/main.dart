import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hua/chat/views/chat_page.dart';
import 'package:hua/chat/providers/chat_provider.dart';
import 'package:hua/services/notification_service.dart';
import 'package:hua/services/fcm_service.dart';
import 'package:hua/profile/views/my_profile_page.dart';
import 'package:hua/profile/providers/my_profile_provider.dart';
import 'package:hua/about/views/about_view.dart';
import 'package:hua/theme/app_theme.dart';
import 'package:hua/theme/theme_controller.dart';
import 'package:hua/webrtc/providers/webrtc_provider.dart';
import 'package:provider/provider.dart';
import 'auth/providers/auth_provider.dart';
import 'auth/views/login_page.dart';
import 'auth/views/signup_page.dart';
import 'splash/views/splashpage.dart';
import 'users_profile/providers/user_profile_provider.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized before we do anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service early
  await NotificationService().init();

  // Initialize FCM service
  await FCMService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ChatProvider _chatProvider = ChatProvider();

  @override
  void initState() {
    super.initState();
    // Register as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister observer when app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pass the app lifecycle state to the chat provider
    _chatProvider.handleAppLifecycleState(state);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _chatProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => MyProfileProvider()),
        ChangeNotifierProvider(create: (_) => WebRTCProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'HUA Chat App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const SplashPage(),
            routes: {
              '/splashpage': (context) => const SplashPage(),
              '/loginpage': (context) => const LoginPage(),
              '/signuppage': (context) => const SignupPage(),
              // '/homepage': (context) => const Homepage(),
              '/chatpage': (context) => const ChatPage(),
              // '/usernamepage': (context) => const UsernamePage(),
              '/profilepage': (context) => const ProfilePage(),
              '/about': (context) => const AboutView(),
              // '/web-rtc': (context) => const WebRTCPage(),
            },
          );
        },
      ),
    );
  }
}
