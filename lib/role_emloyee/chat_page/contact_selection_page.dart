import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_feed_neoflex/features/auth/auth_repository_impl.dart';
import 'package:get_it/get_it.dart';


class ContactSelectionPage extends StatelessWidget {
  final List<UserDTO> users;
  final String accessToken;
  final String avatarBaseUrl;

  const ContactSelectionPage({
    super.key,
    required this.users,
    required this.avatarBaseUrl,
    required this.accessToken
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите контакт'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: user.avatarUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.avatarUrl!.startsWith('http')
                            ? user.avatarUrl!
                            : '$avatarBaseUrl${user.avatarUrl!.startsWith('/') 
                                ? user.avatarUrl!.substring(1) 
                                : user.avatarUrl}',
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
              Navigator.pop(context, user);
            },
          );
        },
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:openapi/openapi.dart';

// class ContactSelectionPage extends StatelessWidget {
//   final List<UserDTO> users;

//   const ContactSelectionPage({
//     super.key,
//     required this.users,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Выберите контакт'),
//       ),
//       body: ListView.builder(
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final user = users[index];
//           return ListTile(
//             leading: CircleAvatar(
//               backgroundImage:
//                   user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//               child: user.avatarUrl == null ? const Icon(Icons.person) : null,
//             ),
//             title: Text('${user.firstName} ${user.lastName}'),
//             subtitle: Text(user.appointment ?? ''),
//             onTap: () {
//               Navigator.pop(context, user);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
