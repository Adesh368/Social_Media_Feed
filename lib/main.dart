import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/feed_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'theme/app_theme.dart';

/// The root widget of the app. Wraps the app in a ProviderScope for Riverpod.
/// Configures theming for light and dark modes and sets up named routes.
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media Feed',

      // Light theme that will be used when system brightness is light
      theme: AppTheme.lightTheme,
      
      // Dark theme for dark system brightness or manual selection
      darkTheme: AppTheme.darkTheme,

      // Use system theme mode; can be controlled by a Provider if needed
      themeMode: ThemeMode.system,

      // Initial route displayed on app launch
      initialRoute: FeedScreen.routeName,

      // Route table mapping route names to screen widgets
      routes: {
        FeedScreen.routeName: (context) => const FeedScreen(),
        PostDetailScreen.routeName: (context) => const PostDetailScreen(),
        UserProfileScreen.routeName: (context) => const UserProfileScreen(),
      },
    );
  }
}
