import 'package:openapi/openapi.dart';

class Post {
  final int? id;
  String text;
  List<String> imageUrls;
  final DateTime createdWhen;
  int likesCount;
  bool isLiked;
  List<Comment> comments;

  Post({
    this.id,
    required this.text,
    required this.imageUrls,
    required this.createdWhen,
    required this.likesCount,
    this.isLiked = false,
    List<Comment>? comments,
  }) : comments = comments ?? [];

  // В классе Post исправьте factory constructor
  factory Post.fromResponseDto(PostResponseDTO dto) {
    return Post(
      id: dto.id?.toInt(),
      createdWhen: dto.createdWhen?.toLocal() ?? DateTime.now(),
      text: dto.text ?? '',
      imageUrls: dto.media
              ?.map((m) => m.downloadUrl ?? '')
              .where((url) => url.isNotEmpty)
              .toList() ??
          [],
      likesCount: dto.likeCount?.toInt() ?? 0,
      isLiked: dto.liked ?? false,
    );
  }
}

class Comment {
  final int id;
  final String text;
  final int userId;
  final String userAvatar;
  final String userName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.userAvatar,
    required this.userName,
    required this.createdAt,
  });
}
