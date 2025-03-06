//добавление новостного поста в ленту

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_feed_neoflex/horizontal_image_slider.dart';
import 'package:news_feed_neoflex/new_post_page.dart';
import 'package:file_picker/file_picker.dart';
import 'publication_page.dart';
import 'dart:io';

class Post {
  final List<String> imageUrls;
  //+
  //final String textFileName;
  final String text;
  final List<String> comments;
  bool isLiked;
  int likesCount;
  //-
  final List<PlatformFile> selectedFiles;

  Post({
    required this.imageUrls,
    //required this.textFileName,
    required this.text,
    required this.comments,
    //-
    required this.selectedFiles,
    this.isLiked = false,
    this.likesCount = 0,
  });
}

class NewsFeed extends StatefulWidget {
  const NewsFeed({Key? key}) : super(key: key);

  @override
  NewsFeedState createState() => NewsFeedState();
}

class NewsFeedState extends State<NewsFeed> {
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;
  List<Post> posts = [];
  List<bool> showCommentInput = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String jsonString =
          await rootBundle.loadString('assets/images.json');
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final List<dynamic> postsData = json['posts'];

      List<Post> newPosts = [];
      for (var postData in postsData) {
        List<String> imageUrls = List<String>.from(
            (postData['images'] as List<dynamic>)
                .map((imageName) => 'assets/images/$imageName'));
        String text = postData['text'] ?? ""; // Load text directly from JSON

        newPosts.add(
          Post(
            imageUrls: imageUrls,
            text: text,
            comments: const [],
            selectedFiles: const [],
          ),
        );
        showCommentInput.add(false); // Initialize comment input visibility
      }

      setState(() {
        posts = newPosts;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void addComment(int index, String comment) {
    if (comment.isNotEmpty) {
      setState(() {
        posts[index].comments.add(comment);
        _controller.clear();
      });
    }
  }

  void toggleCommentInput(int index) {
    setState(() {
      // Check if the index is within the bounds of the list
      if (index < showCommentInput.length) {
        showCommentInput[index] = !showCommentInput[index];
      } else {
        // If index is out of bounds, extend list and set to true
        showCommentInput.length = index + 1;
        showCommentInput[index] = true;
      }
    });
  }

  void toggleLike(int index) {
    setState(() {
      posts[index].isLiked = !posts[index].isLiked;
      posts[index].likesCount += posts[index].isLiked ? 1 : -1;
    });
  }

  // ADDED: _navigateToNewPostPage method
  Future<void> _navigateToNewPostPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewPostPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      final List<File> selectedImages =
          (result['selectedImages'] as List<File>?) ?? [];
      final String text = result['text'] as String? ?? '';
      final List<PlatformFile> selectedFiles =
          (result['selectedFiles'] as List<PlatformFile>?) ?? [];

      setState(() {
        posts.insert(
          0,
          Post(
            imageUrls: selectedImages.map((file) => file.path).toList(),
            text: text,
            comments: [],
            selectedFiles: selectedFiles,
          ),
        );
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/page2');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/page3',
          arguments: {'title': 'New title2'});
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Column(
          children: [
            AppBar(
              foregroundColor: Colors.purple,
              leading: const Icon(Icons.image),
              title: const Align(
                alignment: Alignment.centerLeft,
                child: Text("Главная"),
              ),
              // ADDED: IconButton with onPressed: _navigateToNewPostPage
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _navigateToNewPostPage,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // Handle notification functionality
                  },
                ),
              ],
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.imageUrls.isNotEmpty)
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: 500,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: HorizontalImageSlider(
                              imageUrls: post.imageUrls,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          post.text,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      if (post.selectedFiles.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Attached Files:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ...post.selectedFiles
                                .map((file) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(file.name),
                                    ))
                                .toList(),
                          ],
                        ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              post.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: post.isLiked ? Colors.red : null,
                            ),
                            onPressed: () => toggleLike(index),
                          ),
                          Text('${post.likesCount}'),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () => toggleCommentInput(index),
                          ),
                        ],
                      ),
                      if (showCommentInput.length > index &&
                          showCommentInput[index]) ...[
                        for (var comment in post.comments)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('- $comment'),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                onSubmitted: (value) =>
                                    addComment(index, value),
                                decoration: const InputDecoration(
                                    labelText: 'Напишите комментарий...'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                String commentText = _controller.text.trim();
                                addComment(index, commentText);
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 50),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
