import 'dart:convert';
import 'dart:io';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:news_feed_neoflex/app_routes.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:news_feed_neoflex/features/auth/presentation/screens/login_screen.dart';
import 'package:news_feed_neoflex/horizontal_image_slider.dart';
import 'package:news_feed_neoflex/post_model.dart';
import 'package:news_feed_neoflex/role_manager/edit_post_page.dart';
import 'package:news_feed_neoflex/role_manager/new_post_page/publication_page.dart';
import 'package:news_feed_neoflex/role_manager/users_page/user_profile_page.dart';
import 'package:openapi/openapi.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:news_feed_neoflex/features/notification/presentation/notifications_page.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  NewsFeedState createState() => NewsFeedState();
}

class NewsFeedState extends State<NewsFeed> {
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;
  List<Post> posts = [];
  List<Post> filteredPosts = [];
  List<bool> showCommentInput = [];
  bool isLoading = false;
  String _sortBy = 'date';
  bool _sortAscending = false;
  bool _showFilters = false;

  DateTime? _selectedDate;
  String? _currentUserRole;
  bool _isRoleLoaded = false;
  bool _isAdmin = false;
  String? _errorMessage;
  bool _isLoading = false;
  final CommentControllerApi _commentApi =
      GetIt.I<Openapi>().getCommentControllerApi();
  final LikeControllerApi _likeApi = GetIt.I<Openapi>().getLikeControllerApi();
  int? _currentUserId;
  late String _avatarBaseUrl;
  late String _accessToken;
  bool _postCreationMessageShown = false;
  bool _showCommentsPanel = false;
  int? _currentPostIndex;
  Comment? _replyingTo; // Комментарий, на который отвечаем
  bool _showDeleteOption = false; // Показывать ли опцию удаления
  int? _commentToDelete;

  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    filteredPosts = [];
    final dio = GetIt.I<Dio>();
    _avatarBaseUrl = dio.options.baseUrl;
    if (!_avatarBaseUrl.endsWith('/')) {
      _avatarBaseUrl += '/';
    }
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
    if (token == null) {
      _handleInvalidToken();
      return;
    }

    setState(() {
      _accessToken = token;
    });

    final dio = GetIt.I<Dio>();
    dio.options.headers['Authorization'] = 'Bearer $token';

    await Future.wait([
      _loadUserRole(),
      loadPosts(),
    ]);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadNotificationCount());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForPostCreationMessage();
  }

  void _checkForPostCreationMessage() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map?;
    if (routeArgs?['postCreated'] == true &&
        mounted &&
        !_postCreationMessageShown) {
      // Проверяем флаг

      setState(() {
        _postCreationMessageShown = true; // Устанавливаем флаг
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пост успешно создан!'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  Future<void> _loadNotificationCount() async {
    try {
      final api = GetIt.I<Openapi>().getNotificationControllerApi();
      final response = await api.getNotificationsCount();
      if (mounted) {
        setState(() => _notificationCount = response.data ?? 0);
      }
    } catch (e) {
      debugPrint('Error loading notification count: $e');
    }
  }

  Future<void> _loadUserRole() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      if (token == null) {
        throw Exception('No access token');
      }

      final dio = GetIt.I<Dio>();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final userApi = GetIt.I<Openapi>().getUserControllerApi();
      final response = await userApi.getCurrentUser();

      if (response.data!.roleName == null || response.data == null) {
        throw Exception('Failed to load user role');
      }

      setState(() {
        _currentUserRole = response.data!.roleName?.toUpperCase().trim();
        _isAdmin = _currentUserRole == 'ROLE_ADMIN';
        _currentUserId = response.data!.id?.toInt();
        _isRoleLoaded = true;
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _handleInvalidToken();
      } else {
        debugPrint('Error loading user role: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
  }

  void _handleInvalidToken() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.loginPage,
      (route) => false,
    );
  }

  Future<void> loadPosts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
      final dio = GetIt.I<Dio>();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final postApi = GetIt.I<Openapi>().getPostControllerApi();
      final userApi = GetIt.I<Openapi>().getUserControllerApi();

      final response = await postApi.getAllPosts(
        sortBy: _sortBy,
        page: 0,
        size: 100,
      );

      if (response.statusCode != 200 || response.data == null) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final pageResponse = response.data!;
      final postDTOs = pageResponse.content ?? BuiltList<PostResponseDTO>();

      final newPosts = await Future.wait(postDTOs.map((dto) async {
        final post = Post.fromResponseDto(dto);

        // Используем значение liked из основного ответа
        if (_currentUserId != null) {
          post.isLiked = dto.liked ?? false;
        }

        // Загружаем комментарии с информацией о пользователях
        try {
          final commentsResponse =
              await _commentApi.getComments(postId: post.id!);
          if (commentsResponse.data != null) {
            post.comments =
                await Future.wait(commentsResponse.data!.map((c) async {
              // Если userId null, возвращаем анонимный комментарий
              if (c.userId == null) {
                return Comment(
                  id: c.id ?? -1,
                  text: c.text ?? 'Без текста',
                  userId: -1,
                  userAvatar: '',
                  userName: 'Аноним',
                  createdAt: c.createdWhen?.toLocal() ?? DateTime.now(),
                );
              }

              try {
                // Загружаем данные пользователя
                final userResponse = await userApi.getUserById(id: c.userId!);
                final user = userResponse.data;

                // Формируем URL аватарки с использованием _avatarBaseUrl
                String avatarUrl = '';
                if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
                  avatarUrl = user.avatarUrl!.startsWith('http')
                      ? user.avatarUrl!
                      : '$_avatarBaseUrl${user.avatarUrl!.startsWith('/') ? user.avatarUrl!.substring(1) : user.avatarUrl}';
                }

                return Comment(
                  id: c.id ?? -1,
                  text: c.text ?? 'Без текста',
                  userId: c.userId!,
                  userAvatar: avatarUrl,
                  userName: user != null
                      ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                      : 'Аноним',
                  createdAt: c.createdWhen?.toLocal() ?? DateTime.now(),
                );
              } catch (e) {
                debugPrint('Error loading user data for comment: $e');
                return Comment(
                  id: c.id ?? -1,
                  text: c.text ?? 'Без текста',
                  userId: c.userId ?? -1,
                  userAvatar: '',
                  userName: 'Аноним',
                  createdAt: c.createdWhen?.toLocal() ?? DateTime.now(),
                );
              }
            }).toList());
          }
        } catch (e) {
          debugPrint('Error loading comments: $e');
          post.comments = [];
        }

        return post;
      }));

      setState(() {
        posts = newPosts;
        filteredPosts = [...newPosts];
        showCommentInput = List.generate(newPosts.length, (index) => false);
        _currentPostIndex = null;
      });
    } on DioException catch (e) {
      debugPrint('DioError: ${e.message}');
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.message}';
      });
      if (e.response?.statusCode == 401) {
        _handleInvalidToken();
      }
    } catch (e, stack) {
      debugPrint('Error: $e\n$stack');
      setState(() {
        _errorMessage = 'Неизвестная ошибка';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshToken() async {
    try {
      // Здесь должна быть логика обновления токена
      // Например, через Auth0 или ваш сервер аутентификации
      // После успешного обновления сохраните новый токен
    } catch (e) {
      print('Error refreshing token: $e');
      _handleInvalidToken();
    }
  }

  Future<String> loadText(String fileName) async {
    try {
      return await rootBundle.loadString('assets/text/$fileName');
    } catch (e) {
      print('Error loading text: $fileName - $e');
      return 'Текст не найден';
    }
  }

  Future<void> addComment(int index, String comment) async {
    if (comment.isEmpty || _currentUserId == null) return;
    try {
      final post = filteredPosts[index];
      final response = await _commentApi.createComment(
        postId: post.id!,
        commentDTO: CommentDTO((b) => b..text = comment),
      );

      if (response.data != null) {
        // Получаем данные текущего пользователя
        final userApi = GetIt.I<Openapi>().getUserControllerApi();
        final userResponse = await userApi.getCurrentUser();
        final user = userResponse.data;

        // Формируем URL аватарки
        String avatarUrl = '';
        if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
          avatarUrl = user.avatarUrl!.startsWith('http')
              ? user.avatarUrl!
              : '$_avatarBaseUrl${user.avatarUrl!.startsWith('/') ? user.avatarUrl!.substring(1) : user.avatarUrl}';
        }

        setState(() {
          filteredPosts[index].comments.add(Comment(
                id: response.data!.id!,
                text: response.data!.text ?? comment,
                userId: _currentUserId!,
                userAvatar: avatarUrl,
                userName: user != null
                    ? '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim()
                    : 'Аноним',
                createdAt:
                    response.data!.createdWhen?.toLocal() ?? DateTime.now(),
              ));
          _controller.clear();
        });
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ошибка: не удалось добавить комментарий')),
        );
      }
    }
  }

  void toggleCommentInput(int index) {
    setState(() {
      if (index < showCommentInput.length) {
        showCommentInput[index] = !showCommentInput[index];
      } else {
        showCommentInput.length = index + 1;
        showCommentInput[index] = true;
      }
    });
  }

  Future<void> toggleLike(int index) async {
    if (!mounted) return;

    final post = filteredPosts[index];
    if (post.id == null || _currentUserId == null) {
      debugPrint('Invalid post or user ID');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (post.isLiked) {
        // Пробуем удалить лайк
        final response = await _likeApi.deleteLike(
          postId: post.id!,
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            filteredPosts[index].isLiked = false;
            filteredPosts[index].likesCount--;
          });
        } else {
          debugPrint('Failed to remove like: ${response.statusCode}');
          throw Exception('Failed to remove like: ${response.statusCode}');
        }
      } else {
        // Пробуем добавить лайк
        final response = await _likeApi.createLike(postId: post.id!);

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            filteredPosts[index].isLiked = true;
            filteredPosts[index].likesCount++;
          });
        } else {
          debugPrint('Failed to add like: ${response.statusCode}');
          throw Exception('Failed to add like: ${response.statusCode}');
        }
      }
    } on DioException catch (e) {
      debugPrint('Error toggling like: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: не удалось ${post.isLiked ? 'удалить' : 'поставить'} лайк',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error toggling like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Произошла ошибка при изменении лайка'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) async {
    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.bookPage);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.chatPage);
    } else if (index == 3) {
      if (_isAdmin) {
        Navigator.pushNamed(context, AppRoutes.listOfUsers);
      } else {
        try {
          final userApi = GetIt.I<Openapi>().getUserControllerApi();
          final response = await userApi.getCurrentUser();
          if (response.data != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userData: {
                    'id': response.data!.id?.toString() ?? '',
                    'fio':
                        '${response.data!.firstName ?? ''} ${response.data!.lastName ?? ''} ${response.data!.patronymic ?? ''}',
                    'phone': response.data!.phoneNumber ?? '',
                    'position': response.data!.appointment ?? '',
                    'role': response.data!.roleName ?? 'ROLE_USER',
                    'login': response.data!.login ?? '',
                    'birthDate': response.data!.birthday?.toString() ?? '',
                    'avatarUrl': response.data!.avatarUrl ?? '',
                  },
                  onSave: (updatedUser) async {
                    try {
                      await GetIt.I<Openapi>()
                          .getUserControllerApi()
                          .updateCurrentUser(userDTO: updatedUser);

                      final updatedResponse = await userApi.getCurrentUser();
                      if (updatedResponse.data != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Профиль успешно обновлен')),
                        );
                      }
                    } catch (e) {
                      debugPrint('API Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Ошибка сохранения: ${e.toString()}')),
                      );
                      rethrow;
                    }
                  },
                  onDelete: (userId) {
                    // Логика удаления
                  },
                  onAvatarChanged: (file) {
                    // Логика обновления аватара
                  },
                  isAdmin: false,
                ),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка загрузки профиля: ${e.toString()}')),
          );
        }
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _applyDateFilter() {
    setState(() {
      if (_selectedDate == null) {
        filteredPosts = List.from(posts);
      } else {
        filteredPosts = posts
            .where((post) =>
                post.createdWhen.year == _selectedDate?.year &&
                post.createdWhen.month == _selectedDate?.month &&
                post.createdWhen.day == _selectedDate?.day)
            .toList();
      }
      _applySort();
    });
  }

  void _applySort() {
    setState(() {
      if (_sortBy == 'date') {
        filteredPosts.sort((a, b) => _sortAscending
            ? a.createdWhen.compareTo(b.createdWhen)
            : b.createdWhen.compareTo(a.createdWhen));
      } else if (_sortBy == 'popularity') {
        filteredPosts.sort((a, b) => _sortAscending
            ? (a.likesCount).compareTo(b.likesCount)
            : (b.likesCount).compareTo(a.likesCount));
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _applyDateFilter();
      });
    }
  }

  void _navigateToEditPost(BuildContext context, Post post, int index) async {
    bool isDeleted = false;
    final originalIndex = posts.indexWhere((p) => p.id == post.id);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(
          postId: post.id,
          initialText: post.text,
          initialImagePaths: [...post.imageUrls],
          onSave: (newText, newImages, isSuccess) async {
            try {
              setState(() {
                posts[originalIndex].text = newText;
                posts[originalIndex].imageUrls = [...newImages];
                filteredPosts[index].text = newText;
                filteredPosts[index].imageUrls = [...newImages];
              });

              if (isSuccess) {
                await loadPosts();
              }
              return true;
            } catch (e) {
              debugPrint('Error updating post: $e');
              throw e;
            }
          },
          onDelete: () async {
            try {
              final token =
                  await GetIt.I<AuthRepositoryImpl>().getAccessToken();
              if (token == null) throw Exception('Необходима авторизация');

              if (post.id != null) {
                final postApi = GetIt.I<Openapi>().getPostControllerApi();
                await postApi.deletePost(id: post.id!);

                setState(() {
                  posts.removeWhere((p) => p.id == post.id);
                  filteredPosts.removeWhere((p) => p.id == post.id);
                  showCommentInput.removeAt(index);
                });
                isDeleted = true;
                return true;
              }
              return false;
            } catch (e) {
              debugPrint('Error deleting post: $e');
              throw e;
            }
          },
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isDeleted ? 'Пост успешно удален' : 'Пост успешно сохранен'),
        ),
      );
    }
  }

  Future<void> _showDeleteCommentDialog(int postId, int commentId) async {
    // Добавим отладочную печать для проверки вызова
    debugPrint('Attempting to delete comment $commentId from post $postId');

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить комментарий?'),
        content: const Text('Вы уверены, что хотите удалить этот комментарий?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        setState(() => _isLoading = true);

        await _commentApi.deleteComment(
          postId: postId,
          commentId: commentId,
        );

        // Находим и обновляем пост
        final postIndex = filteredPosts.indexWhere((p) => p.id == postId);
        if (postIndex != -1) {
          setState(() {
            filteredPosts[postIndex]
                .comments
                .removeWhere((c) => c.id == commentId);
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Комментарий успешно удалён')),
          );
        }
      } on DioException catch (e) {
        debugPrint('Error deleting comment: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка удаления: ${e.message}')),
          );
        }
      } catch (e) {
        debugPrint('Unexpected error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Произошла ошибка')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildCommentsPanel(int index) {
    final post = filteredPosts[index];
    return Stack(
      children: [
        // Затемнение фона
        GestureDetector(
          onTap: () {
            setState(() {
              _showCommentsPanel = false;
              _replyingTo = null;
            });
          },
          child: Container(color: Colors.black54),
        ),
        // Сама панель комментариев
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                // Перенесли child Column на уровень Container
                children: [
                  // Заголовок
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _showCommentsPanel = false;
                              _replyingTo = null;
                            });
                          },
                        ),
                        Text(
                          'Комментарии (${post.comments.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_replyingTo != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Ответ на ${_replyingTo!.userName}',
                            style: TextStyle(color: Colors.grey),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _replyingTo = null),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Список комментариев
                  Expanded(
                    child: post.comments.isEmpty
                        ? const Center(child: Text('Нет комментариев'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: post.comments.length,
                            itemBuilder: (context, commentIndex) {
                              final comment = post.comments[commentIndex];
                              final isCurrentUser =
                                  comment.userId == _currentUserId;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact(); // Вибрация
                                  setState(() {
                                    _replyingTo = comment;
                                    _controller.text = '@${comment.userName} ';
                                  });
                                },
                                onLongPress: isCurrentUser
                                    ? () {
                                        HapticFeedback
                                            .lightImpact(); // Вибрация
                                        _showDeleteCommentDialog(
                                            post.id!, comment.id!);
                                      }
                                    : null,
                                child: Container(
                                  color: _replyingTo?.id == comment.id
                                      ? Colors.grey[100]
                                      : Colors.white,
                                  child: ListTile(
                                    leading:
                                        _buildCommentAvatar(comment.userAvatar),
                                    title: Text(comment.userName),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(comment.text),
                                        if (comment.createdAt != null)
                                          Text(
                                            DateFormat('dd.MM.yyyy HH:mm')
                                                .format(comment.createdAt),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                    trailing: isCurrentUser
                                        ? PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert,
                                                size: 16),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                _showDeleteCommentDialog(
                                                    post.id!, comment.id!);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Удалить',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Поле ввода с учетом ответа на комментарий
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (_replyingTo != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Text('Ответ для: '),
                                Text(
                                  _replyingTo!.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => setState(() {
                                    _replyingTo = null;
                                    _controller.text = '';
                                  }),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: _replyingTo != null
                                      ? 'Ответ для ${_replyingTo!.userName}...'
                                      : 'Напишите комментарий...',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(255, 104, 102, 102),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.purple, width: 2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon:
                                  const Icon(Icons.send, color: Colors.purple),
                              onPressed: () {
                                final commentText = _controller.text.trim();
                                // if (commentText.isNotEmpty) {
                                //   if (_replyingTo != null) {
                                //     addComment(index,
                                //         '@${_replyingTo!.userName} $commentText');
                                //     _replyingTo = null;
                                //   } else {
                                //     addComment(index, commentText);
                                //   }
                                //   _controller.clear();
                                // }
                                addComment(index, commentText);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    // Формируем полный URL
    final fullUrl = avatarUrl.startsWith('http')
        ? avatarUrl
        : '$_avatarBaseUrl${avatarUrl.startsWith('/') ? avatarUrl.substring(1) : avatarUrl}';

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: fullUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        httpHeaders: {
          'Authorization': 'Bearer $_accessToken',
        },
        placeholder: (context, url) => Container(
          width: 40,
          height: 40,
          color: Colors.grey,
          child: const Icon(Icons.person, size: 20, color: Colors.white),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Ошибка загрузки аватара: $error');
          return Container(
            width: 40,
            height: 40,
            color: Colors.grey,
            child: const Icon(Icons.error, size: 20),
          );
        },
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 375;
          return Column(
            children: [
              isSmallScreen
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Фильтр по дате:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                onPressed: () => _selectDate(context),
                                child: Text(
                                  _selectedDate == null
                                      ? 'Выберите дату'
                                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedDate = null;
                                    _applyDateFilter();
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Text('Фильтр по дате:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        const SizedBox(width: 10),
                        IntrinsicWidth(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _selectedDate == null
                                  ? 'Выберите дату'
                                  : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _applyDateFilter();
                              });
                            },
                          ),
                      ],
                    ),
              const SizedBox(height: 12),
              isSmallScreen
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Сортировка:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _sortBy,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'date',
                                    child: Text('По дате'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'popularity',
                                    child: Text('По популярности'),
                                  ),
                                ],
                                onChanged: (String? value) {
                                  setState(() {
                                    _sortBy = value!;
                                    _applySort();
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: Colors.purple,
                              ),
                              onPressed: () {
                                setState(() {
                                  _sortAscending = !_sortAscending;
                                  _applySort();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const Text('Сортировка:',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                        const SizedBox(width: 40),
                        IntrinsicWidth(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _sortBy,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            items: const [
                              DropdownMenuItem(
                                value: 'date',
                                child: Text('По дате'),
                              ),
                              DropdownMenuItem(
                                value: 'popularity',
                                child: Text('По популярности'),
                              ),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                _sortBy = value!;
                                _applySort();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.purple,
                          ),
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                              _applySort();
                            });
                          },
                        ),
                      ],
                    ),

              const SizedBox(height: 12),

              // Кнопка сброса
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.refresh, size: 24),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                      _sortBy = 'date';
                      _sortAscending = true;
                      filteredPosts = List.from(posts);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    debugPrint('Current user ID: $_currentUserId');
    if (_currentPostIndex != null && filteredPosts.isNotEmpty) {
      debugPrint(
          'Current post comments: ${filteredPosts[_currentPostIndex!].comments.length}');
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Neoflex",
            style: TextStyle(
              fontFamily: 'Osmo Font',
              fontSize: 40.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PublicationPage()),
                );

                if (result == true) {
                  await loadPosts(); // Обновляем посты только при успешном создании
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пост успешно создан!')),
                  );
                }
              },
            ),
          IconButton(
            icon: badges.Badge(
              showBadge: _notificationCount > 0,
              badgeContent: Text(
                '$_notificationCount',
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.notifications_none),
            ),
            onPressed: () async {
              final userApi = GetIt.I<Openapi>().getUserControllerApi();
              final currentUser = await userApi.getCurrentUser();
              if (currentUser.data != null) {
                // Добавьте await и обновление после возврата
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsPage(
                      currentUserId: currentUser.data!.id!,
                    ),
                  ),
                );

                // Обновляем счетчик после закрытия страницы уведомлений
                if (mounted) {
                  await _loadNotificationCount();
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
          if (_showFilters) _buildFilterControls(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: filteredPosts.isEmpty
                  ? const Center(
                      child: Text('Нет постов, соответствующих вашему запросу'))
                  : ListView.builder(
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        if (index >= filteredPosts.length) {
                          return const SizedBox.shrink();
                        }
                        final post = filteredPosts[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                                top: 50.0,
                                bottom: 30,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${post.createdWhen.day}.${post.createdWhen.month}.${post.createdWhen.year}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            if (post.imageUrls.isNotEmpty)
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  height: 500,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: HorizontalImageSlider(
                                    imageUrls: post.imageUrls,
                                    dio: GetIt.I<Dio>(),
                                    authRepo: GetIt.I<AuthRepositoryImpl>(),
                                  ),
                                ),
                              ),
                            if (post.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                child: Text(
                                  post.text,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    post.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        post.isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => toggleLike(index),
                                ),
                                Text('${post.likesCount}'),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () {
                                    setState(() {
                                      _showCommentsPanel = true;
                                      _currentPostIndex = index;
                                    });
                                  },
                                ),
                                Text('${post.comments.length}'),
                                if (_isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _navigateToEditPost(
                                        context, post, index),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          if (_showCommentsPanel && _currentPostIndex != null)
            _buildCommentsPanel(_currentPostIndex!),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
