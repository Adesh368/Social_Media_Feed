# social_media_feed

A Flutter social media feed application featuring posts, comments, user profiles, search, and real-time updates.

## Features

- Timeline view of posts with author information  
- Comment threads for individual posts with optimistic updates  
- User profile screens showing author details and post lists  
- Local caching with SharedPreferences for offline support  
- Real-time updates via simulated WebSocket events  
- Dark mode support with customizable themes  
- Responsive design for mobile, tablet, and desktop layouts  
- Powerful search to filter posts  

## Getting Started

This project is a starting point for building a modern Flutter social media app.

### Prerequisites

- Flutter SDK installed (version 3.0 or later recommended)  
- An IDE like VS Code, Android Studio, or IntelliJ  
- Basic knowledge of Dart and Flutter development  


## Usage Instructions

- **View Posts Feed:**  
The home screen displays a scrollable timeline of recent posts. Tap a post card to open its detail screen.

- **Search Posts:**  
Use the search bar at the top to filter posts by keyword, instantly narrowing down the feed.

- **View Post Details and Comments:**  
On the post detail screen, read the full post body and browse comments. Add a comment using the input field at the bottom.

- **Create a New Post:**  
Tap the "+" floating button to create a new post. Enter a title and content; your post will appear at the top of the feed.

- **View User Profiles:**  
Tap an author’s avatar or name to navigate to their profile. See their details and all their posts.

- **Dark Mode:**  
The app supports both light and dark themes, following your system settings.

- **Offline Support:**  
If offline, previously cached posts and users will load automatically.

## Architecture Overview

The app is built using **Flutter** and **Riverpod** for state management, following a modular architecture:


**Key Concepts:**
- `AsyncNotifier` + Riverpod for async data fetching and optimistic UI updates.
- Persistent local cache with SharedPreferences for robust offline experiences.
- Real-time updates simulated with timers for demo purposes; hook to real sockets if needed.
- Responsive layout helper for device-specific adaptations.

## Learn More

If you're new to Flutter, here are some useful resources to get you started:

- [Flutter Codelab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)  
- [Flutter Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)  
- [Official Flutter Documentation](https://docs.flutter.dev/) - Tutorials, samples, guidance on mobile development, and full API reference.

## Contribution

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](#) or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE) file for details.

