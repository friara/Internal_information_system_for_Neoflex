import 'package:flutter/material.dart';
import 'package:news_feed_neoflex/main_page.dart';
//import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit(); // инициализация sqflite для использования на десктопе или вебе
  databaseFactory = databaseFactoryFfi;

  runApp(
    const MaterialApp(
      title: 'Dynamic Image List',
      home: MainApp(),
    ),
  );
}
