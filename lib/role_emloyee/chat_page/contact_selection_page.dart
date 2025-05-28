import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:news_feed_neoflex/constans/app_style.dart';
import 'package:openapi/openapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';

class ContactSelectionPage extends StatelessWidget {
  final List<UserDTO> users;
  final String accessToken;
  final String avatarBaseUrl;

  const ContactSelectionPage({
    super.key,
    required this.users,
    required this.avatarBaseUrl,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final dio = GetIt.I<Dio>();
    final baseUrl = dio.options.baseUrl;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Выберите контакт",
            style: AppStyles.heading2,
          ),
        ),
        surfaceTintColor: const Color.fromARGB(255, 100, 29, 113),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final avatarUrl = user.avatarUrl != null
              ? user.avatarUrl!.startsWith('http')
                  ? user.avatarUrl!
                  : '$baseUrl${user.avatarUrl!.startsWith('/') ? user.avatarUrl : '/${user.avatarUrl}'}'
              : null;

          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: avatarUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        httpHeaders: {'Authorization': 'Bearer $accessToken'},
                        placeholder: (context, url) => Container(
                          color: Colors.grey,
                          child: const Icon(Icons.person, size: 20),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 20),
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    )
                  : const Icon(Icons.person),
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.appointment ?? ''),
            onTap: () {
              Navigator.pop(context, user.id);
            },
          );
        },
      ),
    );
  }
}
