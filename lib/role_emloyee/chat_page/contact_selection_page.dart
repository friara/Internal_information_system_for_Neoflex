import 'package:flutter/material.dart';

class ContactSelectionPage extends StatelessWidget {
  final void Function(String) onContactSelected;

  const ContactSelectionPage({
    super.key,
    required this.onContactSelected,
  });

  @override
  Widget build(BuildContext context) {
    final contacts = List.generate(20, (index) => 'Контакт ${index + 1}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите контакт'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/imageMyProfile.jpg"),
            ),
            title: Text(contacts[index]),
            subtitle: const Text('был(а) недавно'),
            onTap: () {
              onContactSelected(contacts[index]);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
