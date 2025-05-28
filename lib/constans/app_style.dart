import 'package:flutter/material.dart';

class AppStyles {
  // Цвета
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color dateColor = Color.fromARGB(255, 85, 84, 84);
  static const Color errorColor = Color(0xFFB00020);
  static const Color purple = Color.fromARGB(255, 163, 60, 179);
  static const Color orange = Color.fromARGB(255, 234, 88, 9);
  static const Color pink = Color.fromARGB(255, 201, 66, 194);

  // Отступы
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 20.0;
  static const double defaultBorderRadius = 8.0;

  // Текстовые стили
  static const TextStyle heading1 = TextStyle(
      fontFamily: 'Osmo Font Regular',
      fontSize: 45.0,
      fontWeight: FontWeight.bold,
      color: Colors.white);

  static const TextStyle heading2 = TextStyle(
      fontFamily: 'Exo 2.0 Light',
      fontSize: 30.0,
      fontWeight: FontWeight.bold,
      color: purple);

  static const TextStyle podheading2 = TextStyle(
      fontFamily: 'Exo 2.0 Light',
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
      color: purple);

  static const TextStyle exitButtonText = TextStyle(
      fontFamily: 'Exo 2.0 Light',
      fontSize: 30.0,
      fontWeight: FontWeight.bold,
      color: Colors.white);

  static const TextStyle deleteButtonText = TextStyle(
      fontFamily: 'Exo 2.0 Light',
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: Colors.white);

  static const TextStyle purpleButtonText = TextStyle(
      fontFamily: 'Exo 2.0 Light',
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
      color: AppStyles.purple);

  // static const TextStyle text1 = TextStyle(
  //   fontFamily: 'Open Sans Light',
  //   fontSize: 17.0,
  //   fontWeight: FontWeight.normal,
  //   color: textColor,
  // );

  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Nunito Black 900 Italic',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle textForDate = TextStyle(
    fontFamily: 'Roboto Light',
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    color: dateColor,
  );

  static const TextStyle textMain = TextStyle(
    fontFamily: 'Nunito Light',
    fontSize: 17.0,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  static const TextStyle textForCommentForAvtor = TextStyle(
    fontFamily: 'Nunito Light',
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle textForComment = TextStyle(
    fontFamily: 'Nunito Light',
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    color: textColor,
  );

  // Стили кнопок
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      padding: const EdgeInsets.all(defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ));

  // Стили картоwhiteчек
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(defaultBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
