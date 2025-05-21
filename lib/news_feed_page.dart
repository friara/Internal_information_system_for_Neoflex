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
  bool _sortAscending = true;
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

  @override
  void initState() {
    super.initState();
    filteredPosts = [];
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();
    if (token == null) {
      _handleInvalidToken();
      return;
    }

    final dio = GetIt.I<Dio>();
    dio.options.headers['Authorization'] = 'Bearer $token';

    await Future.wait([
      _loadUserRole(),
      loadPosts(),
    ]);
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

  // Future<void> loadPosts() async {
  //   if (!mounted) return;

  //   setState(() {
  //     _isLoading = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final token = await GetIt.I<AuthRepositoryImpl>().getAccessToken();

  //     final dio = GetIt.I<Dio>();
  //     dio.options.headers['Authorization'] = 'Bearer $token';

  //     final postApi = GetIt.I<Openapi>().getPostControllerApi();
  //     final response = await postApi.getAllPosts(
  //       sortBy: _sortBy,
  //       page: 0,
  //       size: 100,
  //     );

  //     if (response.statusCode != 200 || response.data == null) {
  //       throw Exception('Server returned ${response.statusCode}');
  //     }

  //     final pageResponse = response.data!;
  //     final postDTOs = pageResponse.content ?? BuiltList<PostResponseDTO>();

  //     // Создаем изменяемый список
  //     final newPosts =
  //         postDTOs.map((dto) => Post.fromResponseDto(dto)).toList();

  //     setState(() {
  //       posts = newPosts;
  //       filteredPosts = [...newPosts]; // Создаем новый изменяемый список
  //       showCommentInput = List.generate(newPosts.length, (index) => false);
  //     });
  //   } on DioException catch (e) {
  //     debugPrint('DioError: ${e.message}');
  //     debugPrint('Response: ${e.response}');

  //     setState(() {
  //       _errorMessage = 'Ошибка загрузки: ${e.message}';
  //     });

  //     if (e.response?.statusCode == 401) {
  //       _handleInvalidToken();
  //     }
  //   } catch (e, stack) {
  //     debugPrint('Error: $e');
  //     debugPrint('Stack: $stack');
  //     setState(() {
  //       _errorMessage = 'Неизвестная ошибка';
  //     });
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

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

                // Формируем URL аватарки
                String avatarUrl = '';
                if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
                  if (user.avatarUrl!.startsWith('http')) {
                    avatarUrl = user.avatarUrl!;
                  } else {
                    avatarUrl =
                        '${dio.options.baseUrl}${user.avatarUrl!.startsWith('/') ? user.avatarUrl!.substring(1) : user.avatarUrl}';
                  }
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
          final dio = GetIt.I<Dio>();
          if (user.avatarUrl!.startsWith('http')) {
            avatarUrl = user.avatarUrl!;
          } else {
            avatarUrl =
                '${dio.options.baseUrl}${user.avatarUrl!.startsWith('/') ? user.avatarUrl!.substring(1) : user.avatarUrl}';
          }
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
            content: Text('Ошибка: не удалось добавить комментарий'),
          ),
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
          userId: _currentUserId!,
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
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPostPage(
            postId: post.id,
            initialText: post.text,
            initialImagePaths: [...post.imageUrls], // Создаем копию списка
            onSave: (newText, newImages) async {
              try {
                // Обновляем локальное состояние
                setState(() {
                  posts[index].text = newText;
                  posts[index].imageUrls = [
                    ...newImages
                  ]; // Создаем копию списка
                  filteredPosts[index].text = newText;
                  filteredPosts[index].imageUrls = [
                    ...newImages
                  ]; // Создаем копию списка
                });
                // Обновляем данные с сервера
                await loadPosts();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Данные успешно сохранены')),
                  );
                }
              } catch (e) {
                debugPrint('Error updating post: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Ошибка сохранения: ${e.toString()}')),
                  );
                }
              }
            },
            onDelete: () async {
              try {
                final token =
                    await GetIt.I<AuthRepositoryImpl>().getAccessToken();
                if (token == null) {
                  throw Exception('Необходима авторизация');
                }

                if (post.id != null) {
                  final postApi = GetIt.I<Openapi>().getPostControllerApi();
                  await postApi.deletePost(id: post.id!);

                  // Удаляем пост из локального состояния
                  setState(() {
                    posts.removeAt(index); // Теперь это работает
                    filteredPosts.removeAt(index); // Теперь это работает
                    if (showCommentInput.length > index) {
                      showCommentInput.removeAt(index);
                    }
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Пост успешно удален')),
                    );
                  }
                }
              } catch (e) {
                debugPrint('Error deleting post: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка удаления: ${e.toString()}')),
                  );
                }
                rethrow;
              }
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при редактировании поста: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildCommentsDialog(int index) {
    final post = filteredPosts[index];
    return AlertDialog(
      title: const Text('Комментарии'),
      content: SizedBox(
        width: double.maxFinite,
        child: post.comments.isEmpty
            ? const Center(child: Text('Нет комментариев'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: post.comments.length,
                itemBuilder: (context, commentIndex) {
                  final comment = post.comments[commentIndex];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Colors.grey, // Серый фон если нет аватарки
                      backgroundImage: comment.userAvatar.isNotEmpty
                          ? CachedNetworkImageProvider(comment.userAvatar)
                          : null,
                      child: comment.userAvatar.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(comment.userName),
                    subtitle: Text(comment.text),
                    trailing: Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(comment.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
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
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        leading: const Icon(Icons.image),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text("Главная"),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PublicationPage()),
                );
              },
            ),
          // IconButton(
          //   icon: const Icon(Icons.notifications_none),
          //   onPressed: () {},
          // ),
        ],
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
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
                        final post = filteredPosts[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                    // Always show comments dialog if there are comments
                                    if (post.comments.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _buildCommentsDialog(index),
                                      );
                                    }
                                    // Toggle comment input regardless
                                    toggleCommentInput(index);
                                  },
                                ),
                                if (_isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _navigateToEditPost(
                                        context, post, index),
                                  ),
                              ],
                            ),
                            if (showCommentInput.length > index &&
                                showCommentInput[index]) ...[
                              for (var comment in post.comments)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                      '- ${comment.text}'), // Было просто '- $comment'
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      onSubmitted: (value) =>
                                          addComment(index, value),
                                      decoration: const InputDecoration(
                                        labelText: 'Напишите комментарий...',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      String commentText =
                                          _controller.text.trim();
                                      addComment(index, commentText);
                                    },
                                  ),
                                ],
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                post.text,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(height: 50),
                          ],
                        );
                      },
                    ),
            ),
          ),
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
