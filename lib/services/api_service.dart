import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/user.dart';
import '../models/comment.dart';

// A service class that handles API requests and data fetching
class ApiService {
  // Base URL for the JSONPlaceholder API
  static final _baseUrl = 'https://jsonplaceholder.typicode.com';

  // Fetch all posts from the API
  static Future<List<Post>> fetchPosts() async {
    // Make GET request to the /posts endpoint
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    // If request is successful (HTTP 200 OK)
    if (response.statusCode == 200) {
      // Decode the JSON response body into a List of dynamic objects
      final List<dynamic> jsonList = json.decode(response.body);
      // Convert each JSON object into a Post instance and return the list
      return jsonList.map((json) => Post.fromJson(json)).toList();
    }
    // Throw an exception if the request fails
    throw Exception('Failed to load posts');
  }

  // Fetch all users from the API
  static Future<List<User>> fetchUsers() async {
    // Make GET request to the /users endpoint
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    // If request is successful
    if (response.statusCode == 200) {
      // Decode JSON and map each object into a User instance
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Failed to load users');
  }

  // Fetch all comments for a specific post
  static Future<List<Comment>> fetchComments(int postId) async {
    // Make GET request with query parameter postId
    final response =
        await http.get(Uri.parse('$_baseUrl/comments?postId=$postId'));

    // If successful
    if (response.statusCode == 200) {
      // Decode JSON and map into Comment instances
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Comment.fromJson(json)).toList();
    }
    throw Exception('Failed to load comments');
  }

  // Create a new post (Simulated — no actual network POST request)
  static Future<Post> createPost(String title, String body, int userId) async {
    // Simulate a network delay of 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Return a new Post object with a mock ID
    return Post(
      id: DateTime.now()
          .millisecondsSinceEpoch, // Unique ID based on current time
      userId: userId,
      title: title,
      body: body,
    );
  }

  // Create a new comment (Simulated — no actual network POST request)
  static Future<Comment> createComment(
      int postId, String body, String authorName) async {
    // Simulate a 1-second delay to mimic API processing
    await Future.delayed(const Duration(seconds: 1));

    // Return a new Comment object with a mock ID
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch, // Unique ID
      postId: postId,
      body: body,
      authorName: authorName,
    );
  }
}
