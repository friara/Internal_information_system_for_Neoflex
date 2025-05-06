class Post {
  List<String> imageUrls;
  final String textFileName;
  String text;
  List<String> comments;
  bool isLiked;
  int likesCount;
  final DateTime date;
  final int views;

  Post({
    required this.imageUrls,
    required this.textFileName,
    required this.text,
    required this.comments,
    required this.date,
    required this.views,
    this.isLiked = false,
    this.likesCount = 0,
  });
}
