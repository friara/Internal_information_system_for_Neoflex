import 'package:cached_network_image/cached_network_image.dart'; // <-- Добавлен пакет
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:openapi/openapi.dart';
import '../features/auth/auth_repository_impl.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late TextEditingController _fiocontroller;
  late TextEditingController _telephoneController;
  late TextEditingController _positionController;
  late TextEditingController _teamController;

  late UserDTO? user;
  String? _authToken; // <-- Храним токен
  int _selectedIndex = 3;
  String _avatarUrl = '';
  bool _isLoading = true;

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/page1');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/page2');
    } else if (index == 0) {
      Navigator.pushNamed(context, '/');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fiocontroller = TextEditingController();
    _telephoneController = TextEditingController();
    _positionController = TextEditingController();
    _teamController = TextEditingController();
    _loadData();
  }

    Future<void> _saveProfile() async {
    try {
      final userApi = GetIt.I<Openapi>().getUserControllerApi();
      final int userId = user!.id!;
      final fioParts = _fiocontroller.text.split(' ');
      
      final userDTO = UserDTO((b) => b
        ..id = userId
        ..lastName = fioParts.isNotEmpty ? fioParts[0] : ''
        ..firstName = fioParts.length > 1 ? fioParts[1] : ''
        ..patronymic = fioParts.length > 2 ? fioParts[2] : ''
        ..appointment = _positionController.text
        ..login = _telephoneController.text
      );

      await userApi.updateCurrentUser(userDTO: userDTO);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно сохранён!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка сохранения профиля')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final authRepo = GetIt.I<AuthRepositoryImpl>();
      final userApi = GetIt.I<Openapi>().getUserControllerApi();
      
      // Получаем токен и логин
      _authToken = await authRepo.getAccessToken(); // <-- Получаем токен
      final String? userLogin = await authRepo.getCurrentUserName();

      if (userLogin == null || userLogin.isEmpty) {
        throw Exception('Логин пользователя не найден');
      }

      final response = await userApi.getCurrentUser();
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }

      user = response.data;

      if (mounted) {
        setState(() {
          if (user != null) {
            _fiocontroller.text = '${user!.lastName} ${user!.firstName} ${user!.patronymic}';
            _telephoneController.text = user!.login ?? '';
            _positionController.text = user!.appointment ?? '';
            _teamController.text = 'Нет';
            _avatarUrl = user!.avatarUrl != null 
                ? 'http://localhost:8080${user!.avatarUrl}'
                : '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildAvatar() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    
    return CachedNetworkImage( // <-- Замена CircleAvatar на CachedNetworkImage
      imageUrl: _avatarUrl,
      httpHeaders: {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken' // <-- Добавляем токен
      },
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 80,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircleAvatar(
        radius: 80,
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage('assets/images/default_avatar.png'),
      ),
    );
  }

  // Остальной код без изменений
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.purple,
        title: const Text("Профиль пользователя"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildAvatar(),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _fiocontroller,
                          label: 'ФИО',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 15),
                        _buildPhoneField(),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _positionController,
                          label: 'Должность',
                          icon: Icons.work,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          controller: _teamController,
                          label: 'Команда',
                          icon: Icons.group,
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.computer), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF48036F),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      readOnly: readOnly,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _telephoneController,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        _PhoneNumberFormatter(),
      ],
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Телефон',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final newText = StringBuffer();

    if (text.length >= 1) {
      newText.write('+7 (${text.substring(1, text.length > 4 ? 4 : text.length)}');
    }
    if (text.length > 4) {
      newText.write(') ${text.substring(4, text.length > 7 ? 7 : text.length)}');
    }
    if (text.length > 7) {
      newText.write('-${text.substring(7, text.length > 9 ? 9 : text.length)}');
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get_it/get_it.dart';
// import 'package:openapi/openapi.dart';
// import '../features/auth/auth_repository_impl.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   late TextEditingController _fiocontroller;
//   late TextEditingController _telephoneController;
//   late TextEditingController _positionController;
//   late TextEditingController _teamController;
//   int _selectedIndex = 3;

//   void _onItemTapped(int index) {
//     if (index == 1) {
//       Navigator.pushNamed(context, '/page1');
//     } else if (index == 2) {
//       Navigator.pushNamed(context, '/page2');
//     } else if (index == 0) {
//       Navigator.pushNamed(context, '/');
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fiocontroller = TextEditingController();
//     _telephoneController = TextEditingController();
//     _positionController = TextEditingController();
//     _teamController = TextEditingController();
//     loadData();
//   }

//   Future<void> loadData() async {
//     try {
//       final userApi = GetIt.I<Openapi>().getUserControllerApi();
//       //final userId = GetIt.I<AuthRepositoryImpl>().getCurrentUserId();

//       final response = await userApi.getUserById(id: 1); // Замените 1 на реальный ID
//       final user = response.data;

//       if (user != null && mounted) {
//         setState(() {
//           _fiocontroller.text = '${user.lastName} ${user.firstName} ${user.patronymic}';
//           _telephoneController.text = user.login ?? '';
//           _positionController.text = user.appointment ?? '';
//           _teamController.text = 'Team A'; // Пример, если нет поля в API
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ошибка загрузки профиля')),
//         );
//       }
//     }
//   }

//   void saveProfile() async {
//     try {
//       final userApi = GetIt.I<Openapi>().getUserControllerApi();
//       final fioParts = _fiocontroller.text.split(' ');
      
//       final userDTO = UserDTO((b) => b
//         ..id = 1 // Замените на реальный ID
//         ..lastName = fioParts.isNotEmpty ? fioParts[0] : ''
//         ..firstName = fioParts.length > 1 ? fioParts[1] : ''
//         ..patronymic = fioParts.length > 2 ? fioParts[2] : ''
//         ..appointment = _positionController.text
//         ..login = _telephoneController.text
//       );

//       await userApi.updateUser(id: 1, userDTO: userDTO);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Профиль сохранен!')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ошибка сохранения')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.purple,
//         title: const Text("Профиль пользователя"),
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: saveProfile,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           const Divider(),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Column(
//               children: [
//                 const CircleAvatar(
//                   radius: 80,
//                   backgroundImage: AssetImage('assets/images/imageMyProfile.jpg'),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   controller: _fiocontroller,
//                   decoration: const InputDecoration(
//                     labelText: 'ФИО',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
//                     LengthLimitingTextInputFormatter(12)
//                   ],
//                   controller: _telephoneController,
//                   decoration: const InputDecoration(
//                     labelText: 'Телефон',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _positionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Должность',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 TextField(
//                   controller: _teamController,
//                   decoration: const InputDecoration(
//                     labelText: 'Команда',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.computer), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.message_sharp), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: const Color(0xFF48036F),
//         unselectedItemColor: Colors.grey,
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import '../database.dart'; // Импортируйте ваш класс DatabaseHelper

// // class Profile extends StatefulWidget {
// //   const Profile({super.key});

// //   @override
// //   _ProfileState createState() => _ProfileState();
// // }

// // class _ProfileState extends State<Profile> {
// //   late TextEditingController _fiocontroller;
// //   late TextEditingController _telephoneController;
// //   late TextEditingController _positionController; // Контроллер для должности
// //   late TextEditingController _teamController; // Контроллер для команды

// //   int _selectedIndex = 3; // Начальный индекс

// //   void _onItemTapped(int index) {
// //     if (index == 1) {
// //       Navigator.pushNamed(context, '/page1');
// //     } else if (index == 2) {
// //       //Индекс для иконки чаты
// //       Navigator.pushNamed(context, '/page2');
// //     } else if (index == 0) {
// //       // Индекс для иконки профиля
// //       Navigator.pushNamed(context, '/');
// //     } else {
// //       setState(() {
// //         _selectedIndex = index; // Обновляем индекс при нажатии
// //       });
// //     }
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fiocontroller = TextEditingController(text: 'Бублик Петрович');
// //     _telephoneController = TextEditingController(text: '123456789');
// //     _positionController = TextEditingController(
// //         text: 'Продукт менеджер'); // Изначально пустое поле
// //     _teamController =
// //         TextEditingController(text: 'Team A'); // Изначально пустое поле
// //     loadData(); // Загружаем данные при инициализации
// //   }

// //   //!!! данные не загружаются из БД
// //   Future<void> loadData() async {
// //     DatabaseHelper dbHelper = DatabaseHelper();

// //     // Загрузка начальных данных из файла и вставка в БД
// //     await dbHelper.loadInitialData();

// //     // Получение профиля из БД
// //     Map<String, dynamic>? profile = await dbHelper.getProfile();

// //     if (profile != null) {
// //       setState(() {
// //         _fiocontroller.text = profile['fio'] ?? ''; // Устанавливаем ФИО из БД
// //         _telephoneController.text = profile['telephone'] ?? '';
// //         _positionController.text =
// //             profile['position'] ?? ''; // Устанавливаем должность из БД
// //         _teamController.text =
// //             profile['team'] ?? ''; // Устанавливаем команду из БД
// //       });
// //     } else {
// //       print("Профиль не найден"); // Отладочная информация
// //     }
// //   }

// //   void saveProfile() {
// //     // Логика для сохранения профиля в базе данных
// //     DatabaseHelper dbHelper = DatabaseHelper();
// //     dbHelper.insertProfile(
// //       _fiocontroller.text,
// //       _telephoneController.text,
// //       _positionController.text,
// //       _teamController.text,
// //     );

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Профиль сохранен!')),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         appBar: AppBar(
// //           foregroundColor: Colors.purple,
// //           title: const Text("Профиль пользователя"),
// //           automaticallyImplyLeading: false,
// //           actions: [
// //             IconButton(
// //               icon: const Icon(Icons.save), // Иконка для кнопки сохранить
// //               onPressed: saveProfile, // Вызов метода сохранения профиля
// //             ),
// //           ],
// //         ),
// //         body: Column(
// //           children: [
// //             const Divider(), // Разделительная линия под AppBar
// //             Padding(
// //               padding: const EdgeInsets.all(12.0),
// //               child: Column(
// //                 children: [
// //                   const CircleAvatar(
// //                     radius: 80,
// //                     backgroundImage:
// //                         AssetImage('assets/images/imageMyProfile.jpg'),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   TextField(
// //                     controller: _fiocontroller,
// //                     decoration: const InputDecoration(
// //                       labelText: 'ФИО',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   TextFormField(
// //                     inputFormatters: [
// //                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
// //                       LengthLimitingTextInputFormatter(12)
// //                     ],
// //                     controller: _telephoneController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'Телефон',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   TextField(
// //                     controller: _positionController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'Должность',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   TextField(
// //                     controller: _teamController,
// //                     decoration: const InputDecoration(
// //                       labelText: 'Команда',
// //                       border: OutlineInputBorder(),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //         // floatingActionButton: FloatingActionButton(
// //         //     onPressed: () async {
// //         //       Navigator.of(context).pop('Result 123');
// //         //     },
// //         //     child: const Icon(Icons.image)), // Кнопка профиля.
// //         bottomNavigationBar: BottomNavigationBar(
// //           items: const <BottomNavigationBarItem>[
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.home),
// //               label: '',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.computer),
// //               label: '',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.message_sharp),
// //               label: '',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person),
// //               label: '',
// //             ),
// //           ],
// //           currentIndex: _selectedIndex, // Индекс выбранного элемента
// //           onTap: _onItemTapped, // Метод для обработки нажатий
// //           selectedItemColor:
// //               const Color(0xFF48036F), // Фиолетовый цвет для выбранного элемента
// //           unselectedItemColor:
// //               Colors.grey, // Серый цвет для невыбранных элементов
// //         ));
// //   }
// // }
