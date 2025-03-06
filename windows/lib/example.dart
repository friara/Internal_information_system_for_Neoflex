//на всякий случай (начальная заготовка)


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:convert';

// // Список изображений и их описаний
// List<Image> imgList = [];
// List<String> imageNames = [];
// List<String> imageTexts = [];
// List<List<String>> comments = []; // Список комментариев для каждого изображения
// List<bool> showCommentInput =
//     []; // Список для управления видимостью текстового поля для комментариев
// List<int> likesCount = []; // Счетчик лайков для каждого изображения
// List<bool> isLiked = []; // Состояние лайка для каждого изображения

// void main() {
//   runApp(
//     MaterialApp(
//       title: 'Dynamic Image List',
//       home: MainApp(),
//     ),
//   );
// }

// class MainApp extends StatefulWidget {
//   const MainApp({super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return MainAppState();
//   }
// }

// class MainAppState extends State<MainApp> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadImageNames(); // Загружаем имена изображений при старте
//   }

//   Future<void> loadImageNames() async {
//     final String response = await rootBundle.loadString('assets/images.json');
//     final data = json.decode(response);

//     setState(() {
//       imageNames = List<String>.from(data['images']);
//       loadImages(); // Загружаем изображения после получения имен
//     });
//   }

//   Future<void> loadImages() async {
//     imgList.clear(); // Очищаем предыдущий список изображений
//     imageTexts.clear(); // Очищаем предыдущий список текстов
//     comments.clear(); // Очищаем предыдущий список комментариев
//     showCommentInput.clear(); // Очищаем список видимости текстовых полей
//     likesCount.clear(); // Очищаем счетчик лайков
//     isLiked.clear(); // Очищаем состояние лайков

//     for (var name in imageNames) {
//       imgList.add(Image.asset('assets/images/$name'));
//       String text = await loadText(
//           name.replaceFirst('.jpg', '.txt')); // Загружаем текст для изображения
//       imageTexts.add(text); // Добавляем текст в список
//       comments.add(
//           []); // Инициализируем пустой список комментариев для каждого изображения
//       showCommentInput
//           .add(false); // Изначально скрываем текстовое поле для комментариев
//       likesCount.add(0); // Изначально количество лайков равно 0
//       isLiked.add(false); // Изначально лайк не поставлен
//     }

//     setState(() {});
//   }

//   Future<String> loadText(String fileName) async {
//     return await rootBundle.loadString('assets/text/$fileName');
//   }

//   void addImage() {
//     String newImageName = _controller.text.trim();
//     if (newImageName.isNotEmpty) {
//       setState(() {
//         imgList.add(Image.asset('assets/images/$newImageName'));
//         imageNames.add(newImageName); // Добавляем имя в список

//         // Загружаем текст для нового изображения (по умолчанию пустой)
//         imageTexts.add("Текст для $newImageName");
//         comments.add([]); // Инициализируем пустой список комментариев

//         showCommentInput.add(false); // Изначально скрываем текстовое поле

//         likesCount.add(0); // Изначально количество лайков равно 0
//         isLiked.add(false); // Изначально лайк не поставлен

//         _controller.clear(); // Очищаем текстовое поле
//       });
//     }
//   }

//   void addComment(int index, String comment) {
//     if (comment.isNotEmpty) {
//       setState(() {
//         comments[index].add(
//             comment); // Добавляем комментарий к соответствующему изображению
//       });
//     }
//   }

//   void toggleCommentInput(int index) {
//     setState(() {
//       showCommentInput[index] = !showCommentInput[
//           index]; // Переключаем видимость текстового поля для комментариев
//     });
//   }

//   void toggleLike(int index) {
//     setState(() {
//       isLiked[index] = !isLiked[index]; // Переключаем состояние лайка
//       if (isLiked[index]) {
//         likesCount[index]++; // Увеличиваем счетчик лайков, если лайк установлен
//       } else {
//         likesCount[index]--; // Уменьшаем счетчик лайков, если лайк снят
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     int imgCount = imgList.length;
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         leading: Icon(Icons.image),
//         title: Text("Dynamic Add Image List"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: addImage,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Enter image name (e.g., f4.jpeg)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: addImage,
//               child: Text('Add Image'),
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Text("Image Count: $imgCount"),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: imgCount,
//                 itemBuilder: (context, index) {
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Container(
//                           width: screenWidth,
//                           height: 300,
//                           margin: EdgeInsets.symmetric(vertical: 5),
//                           child: imgList[index],
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: Icon(
//                               isLiked[index]
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: isLiked[index] ? Colors.red : null,
//                             ),
//                             onPressed: () => toggleLike(
//                                 index), // Обработка нажатия на кнопку "лайк"
//                           ),
//                           Text(
//                               '${likesCount[index]}'), // Отображение количества лайков

//                           SizedBox(width: 10), // Отступ между кнопками

//                           IconButton(
//                             icon: Icon(Icons.message),
//                             onPressed: () => toggleCommentInput(
//                                 index), // Переключение видимости текстового поля для комментариев
//                           ),
//                           Text('${likesCount[index]}'),

//                           // ElevatedButton(
//                           //   onPressed: () => toggleCommentInput(
//                           //       index), // Переключение видимости текстового поля для комментариев
//                           //   child: Text(showCommentInput[index]
//                           //       ? "Скрыть комментарии"
//                           //       : "Добавить комментарий"),
//                           // ),
//                         ],
//                       ),
//                       if (showCommentInput[index]) ...[
//                         for (var comment in comments[index])
//                           Padding(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text('- $comment'),
//                           ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 onSubmitted: (value) => addComment(index,
//                                     value), // Добавление комментария по нажатию Enter
//                                 decoration: InputDecoration(
//                                     labelText: 'Напишите комментарий...'),
//                               ),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.send),
//                               onPressed: () {
//                                 String commentText = _controller.text.trim();
//                                 addComment(index, commentText);
//                                 _controller
//                                     .clear(); // Очищаем текстовое поле после отправки
//                               },
//                             )
//                           ],
//                         ),
//                       ],
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           imageTexts[index],
//                           textAlign: TextAlign.left,
//                         ),
//                       ),
//                       SizedBox(height: 50),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
