import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hua/auth/providers/auth_provider.dart';
import 'package:hua/services/fcm_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Start animation
    _animationController.forward();

    // Check authentication after animation starts
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Allow animation to play a bit before checking auth
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Using the auth provider instead of directly accessing storage
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Initialize auth state if not already done
    if (authProvider.status == AuthStatus.unknown) {
      await authProvider.initialize();
    }

    if (!mounted) return;

    // Wait for a minimum time to show the splash screen
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return; // Navigate based on authentication status
    if (authProvider.isAuthenticated) {
      // User is authenticated, check and update FCM token
      try {
        await FCMService().checkAndUpdateFCMToken();
      } catch (e) {
        debugPrint('Error updating FCM token in splash: $e');
        // Don't block navigation if FCM update fails
      }

      // Go to chat page
      Navigator.of(context).pushReplacementNamed('/chatpage');
    } else {
      // User is not authenticated, go to login page
      Navigator.of(context).pushReplacementNamed('/loginpage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo with shadow for depth
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.chat_rounded,
                          size: 60,
                          color: isDarkMode ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App name with style
                    Text(
                      'HUA Chat',
                      style: TextStyle(
                        color: theme.textTheme.headlineMedium?.color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // App tagline
                    Text(
                      'Connect instantly with everyone',
                      style: TextStyle(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    // SizedBox(
                    //   width: 36,
                    //   height: 36,
                    //   child: CircularProgressIndicator(
                    //     valueColor:
                    //         AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    //     strokeWidth: 3,
                    //   ),
                    // ),
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
