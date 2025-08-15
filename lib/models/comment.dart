class Comment {
  final int id;
  final int postId;
  final String body;
  final String authorName;

  Comment({
    required this.id,
    required this.postId,
    required this.body,
    required this.authorName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        postId: json['postId'],
        body: json['body'],
        authorName: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'body': body,
        'authorName': authorName,
      };
}
