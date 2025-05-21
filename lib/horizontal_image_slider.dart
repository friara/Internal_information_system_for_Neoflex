import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';

class HorizontalImageSlider extends StatelessWidget {
  final List<String> imageUrls;
  final Dio dio;
  final AuthRepositoryImpl authRepo;

  const HorizontalImageSlider({
    Key? key,
    required this.imageUrls,
    required this.dio,
    required this.authRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<String?>(
      future: authRepo.getAccessToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final token = snapshot.data;

        return PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            String fullUrl;

            if (imageUrl.startsWith('http')) {
              fullUrl = imageUrl;
            } else {
              String baseUrl = dio.options.baseUrl;
              if (!baseUrl.endsWith('/')) {
                baseUrl += '/';
              }
              String path =
                  imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
              fullUrl = baseUrl + path;
            }

            debugPrint('Loading image from: $fullUrl with token: $token');

            return CachedNetworkImage(
              imageUrl: fullUrl,
              fit: BoxFit.contain,
              httpHeaders: {
                'Authorization': 'Bearer $token',
              },
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Error loading image: $error');
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error, size: 50, color: Colors.red),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
